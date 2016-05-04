/* SimpleApp.scala */
import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;

import org.apache.accumulo.core.client.BatchWriterConfig;
import org.apache.accumulo.core.client.ZooKeeperInstance;
import org.apache.accumulo.core.client.security.tokens.AuthenticationToken;
import org.apache.accumulo.core.client.security.tokens.PasswordToken;
import org.apache.accumulo.core.data.Mutation;
import org.apache.accumulo.core.data.Value;

import org.apache.accumulo.core.client.mapreduce.AccumuloInputFormat;
import org.apache.accumulo.core.security.Authorizations;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapred.JobConf;

object BDBLoader {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("bdb-loader")
    val sc = new SparkContext(conf)

    val usage = "run <instanceName> <zookeepers> <username> <password>"
    args.length match {
      case 4 => println("Using args:" + args.mkString(" "))
      case _ => {
        println(usage)
        return
      }        
    }

    val instanceName = args(0)
    val zookeepers = args(1)
    val username = args(2)
    val password = args(3)
    
    //check if rankings exists first
    val instance = new ZooKeeperInstance(instanceName, zookeepers);
    val connector = instance.getConnector(username, new PasswordToken(password));
    val to = connector.tableOperations();
    if( to.exists("rankings") ){
      println("deleting rows");
      to.deleteRows("rankings", null, null);
      //to.delete("rankings");
      //to.create("rankings");
    }

    val rankings = sc.textFile("hdfs:///user/spark/benchmark/rankings", 2);
    //val numLines = rankings.count();
    //println("Total lines: %s".format(numLines))

    val uploaded = rankings.foreachPartition( (partitionOfRecords) => {
      val instance = new ZooKeeperInstance(instanceName, zookeepers)    
      val connector = instance.getConnector("root", new PasswordToken("accumulo"))

      val batchWriter = connector.createBatchWriter("rankings", new BatchWriterConfig());
      partitionOfRecords.foreach( (line:String) => {
        val s:Array[String] = line.split(",");
        val url = s(0);
        val ranking = s(1);
        val duration = s(2);

        val m = new Mutation(url);
        m.put("pagerank", "ranking", ranking);
        m.put("pagerank", "duration", duration);
        batchWriter.addMutation(m);
        url;
      });
      batchWriter.close();
    });
    println("num partitions: %s".format(rankings.partitions.size));
    val numUploaded = rankings.count();
    println("Records uploaded: %s".format(numUploaded));
  }
}

object BDBReader {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("bdb-reader")
    val sc = new SparkContext(conf)

    val usage = "run <instanceName> <zookeepers> <username> <password>"
    args.length match {
      case 4 => println("Using args:" + args.mkString(" "))
      case _ => {
        println(usage)
        return
      }        
    }

    val instanceName = args(0)
    val zookeepers = args(1)
    val username = args(2)
    val password = args(3)

    //val hconf = sc.hadoopConfiguration;
    val jobConf = new JobConf()
    val job = new Job(jobConf);


    /* this is such a hacky way of  building an accumulo interface
    but it was the only one that I could make work on 1.7.1
    I'm sure there's some fact about scala interopability with java static methods
    that I'm missing, but here we are for now.
    */

    //classOf[AccumuloInputFormat].getMethods().map( x=>println(x.toString()) );
    //AccumuloInputFormat.setConnectorInfo(jobConf, username, new PasswordToken(password));
    val setConnectorInfo = classOf[AccumuloInputFormat]
      .getMethod("setConnectorInfo", classOf[Job], classOf[String], classOf[AuthenticationToken]);
    setConnectorInfo.invoke(null, job, username, new PasswordToken(password));

    //AccumuloInputFormat.setInputTableName(jobConf, "rankings");
    val setInputTableName = classOf[AccumuloInputFormat]
        .getMethod("setInputTableName", classOf[Job], classOf[String]);
    setInputTableName.invoke(null, job, "rankings");

    //AccumuloInputFormat.setZooKeeperInstance(jobConf, instanceName, zookeepers);
    val setZooKeeperInstance = classOf[AccumuloInputFormat]
        .getMethod("setZooKeeperInstance", classOf[Job], classOf[String], classOf[String]);
    setZooKeeperInstance.invoke(null, job, instanceName, zookeepers);

    //AccumuloInputFormat.setAuthorizatons(new Authorizations());
    val authorizations = new Authorizations();
    val setScanAuthorizations = classOf[AccumuloInputFormat]
        .getMethod("setScanAuthorizations", classOf[Job], classOf[Authorizations]);
    setScanAuthorizations.invoke(null, job, authorizations);

    val rdd = sc.newAPIHadoopRDD(job.getConfiguration(), classOf[AccumuloInputFormat],
      classOf[org.apache.accumulo.core.data.Key],
      classOf[org.apache.accumulo.core.data.Value])
    println("Records read: %s".format(rdd.count()));

  }
}

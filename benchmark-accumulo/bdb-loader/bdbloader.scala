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
    //val numUploaded = uploaded.count();
    //println("Records uploaded: %s".format(numUploaded));
  }
}

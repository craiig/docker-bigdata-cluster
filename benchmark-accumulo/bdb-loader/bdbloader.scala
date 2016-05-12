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

import org.apache.hadoop.io.Text;
import collection.JavaConversions._;

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
      //println("deleting rows");
      //to.deleteRows("rankings", null, null);
      //delete and recreate so we can build splits
      to.delete("rankings");
      to.create("rankings");
      val splits = new java.util.TreeSet[Text]();
      var i = 0;
      for( i <- 0 to 255 ){
        val bytes = Array[Byte](i.toByte);
        splits.add(new Text(bytes));
      }
      to.addSplits("rankings", splits);
    }

    val rankings = sc.textFile("hdfs:///user/spark/benchmark/rankings");
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


/** benchmarking plan
 *  1. execute queries like q1, q2, a3 against accumulo
 *  2. q2,q3 are extra challenging because they do joins
 *  - need to do this in a believable way with a batchscanner etc.
 *  3. somehow measure memory usage??
 */

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

     val ardd = new AccumuloRDD(username, password, "rankings", instanceName,
       zookeepers);
     ardd.getColumn("pagerank", "ranking");
     val rdd = ardd.makeRDD(sc);
     rdd.persist();

     println( rdd.getNumPartitions );
     PerfUtils.getFreeMemory(sc);
     //println("First Record: %s".format(rdd.first()));
     println("Records read: %s".format(rdd.count()));
     PerfUtils.getFreeMemory(sc);
  }
}

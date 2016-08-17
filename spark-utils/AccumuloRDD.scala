import org.apache.spark.rdd.RDD;
import org.apache.spark.SparkContext;
import org.apache.accumulo.core.client.mapreduce.InputFormatBase;
import org.apache.accumulo.core.security.Authorizations;
import org.apache.accumulo.core.client.security.tokens.PasswordToken;
import org.apache.accumulo.core.client.mapreduce.AccumuloInputFormat;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapred.JobConf;
import org.apache.accumulo.core.util.{Pair => AccPair}
import org.apache.hadoop.io.Text;
import collection.JavaConversions._;

import org.apache.spark.storage.RDDUniqueBlockId
import org.apache.accumulo.core.client.mapreduce.RangeInputSplit
import org.apache.hadoop.mapreduce.InputSplit


class AccumuloRDD(username:String, password:String,
    table:String, instanceName:String, zookeepers:String){

    //val hconf = sc.hadoopConfiguration;
    val jobConf = new JobConf()
    val job = new Job(jobConf);

    val aif = AccumuloInputFormatAdapter;
    aif.setConnectorInfo(job, username, new PasswordToken(password));
    aif.setInputTableName(job, table);
    aif.setZooKeeperInstance(job, instanceName, zookeepers);
    aif.setScanAuthorizations(job, new Authorizations());

    var columns = List[AccPair[Text,Text]]();

    def getColumn(family:Text, qualifier:Text) = {
      //columns += (family, qualifier);
      //columns = columns :: (family, qualifier);
      columns = new AccPair[Text,Text](family, qualifier) :: columns;
    }

    def makeRDD(sc:SparkContext)
    : RDD[(org.apache.accumulo.core.data.Key,org.apache.accumulo.core.data.Value)] = {
      //InputFormatBase.fetchColumns( job, List(
        //new AccPair[Text, Text]("pagerank", "ranking"),
        //new AccPair[Text, Text]("pagerank", "duration")
      //));
      InputFormatBase.fetchColumns( job, columns);

      val rdd = sc.newAPIHadoopRDD(
        job.getConfiguration(),
        classOf[AccumuloInputFormat],
        classOf[org.apache.accumulo.core.data.Key],
        classOf[org.apache.accumulo.core.data.Value],
         Some((rdd:RDD[_], inputSplit:InputSplit) => {
          assert (inputSplit.isInstanceOf[RangeInputSplit]) 
            val is:RangeInputSplit = inputSplit.asInstanceOf[RangeInputSplit]
            RDDUniqueBlockId(is.toString)
            //potentialy narrow down the set of identifying attributes for acumulo
            //val range = is.getRange
            //val tablename
            //tableid // /??
            //instancename
            //authenticationtoken
            //fetchcolumns ??
        }) 
      )
      return rdd;
    }
}

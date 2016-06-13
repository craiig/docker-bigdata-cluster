import org.apache.hadoop.mapreduce.Job;
import org.apache.accumulo.core.client.mapreduce.AccumuloInputFormat;
import org.apache.accumulo.core.security.Authorizations;
import org.apache.accumulo.core.client.security.tokens.AuthenticationToken;

object AccumuloInputFormatAdapter {
    /* this is such a hacky way of  building an accumulo interface
    but it was the only one that I could make work on 1.7.1
    I'm sure there's some fact about scala interopability with java static methods
    that I'm missing, but here we are for now.
    see here for more details:
    https://github.com/locationtech/geomesa/blob/master/geomesa-jobs/src/main/scala/org/locationtech/geomesa/jobs/mapreduce/InputFormatBaseAdapter.scala
    */

   def setConnectorInfo(job:Job, username:String, auth:AuthenticationToken){
     //classOf[AccumuloInputFormat].getMethods().map( x=>println(x.toString()) );
     //AccumuloInputFormat.setConnectorInfo(jobConf, username, new PasswordToken(password));
     val setConnectorInfo = classOf[AccumuloInputFormat]
       .getMethod("setConnectorInfo", classOf[Job], classOf[String], classOf[AuthenticationToken]);
     setConnectorInfo.invoke(null, job, username, auth);
   }

   def setInputTableName(job:Job, table:String){
    //AccumuloInputFormat.setInputTableName(jobConf, "rankings");
    val setInputTableName = classOf[AccumuloInputFormat]
      .getMethod("setInputTableName", classOf[Job], classOf[String]);
      setInputTableName.invoke(null, job, table);
   }

   def setZooKeeperInstance(job:Job, instanceName:String, zookeepers:String){
     //AccumuloInputFormat.setZooKeeperInstance(jobConf, instanceName, zookeepers);
     val setZooKeeperInstance = classOf[AccumuloInputFormat]
       .getMethod("setZooKeeperInstance", classOf[Job], classOf[String], classOf[String]);
     setZooKeeperInstance.invoke(null, job, instanceName, zookeepers);
   }

    //AccumuloInputFormat.setAuthorizatons(new Authorizations());
    def setScanAuthorizations(job:Job, auths:Authorizations){
      val setScanAuthorizations = classOf[AccumuloInputFormat]
          .getMethod("setScanAuthorizations", classOf[Job], classOf[Authorizations]);
      setScanAuthorizations.invoke(null, job, auths);
    }
}

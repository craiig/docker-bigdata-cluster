import org.apache.spark.SparkContext;

object PerfUtils {
  def getFreeMemory(sc: SparkContext){
    //var mem:Long = 0;
    sc.getExecutorMemoryStatus.foreach{ case (k,v) => {
      println(k + " is using " + (v._1 - v._2) + "/" + v._1 + " bytes");
      //mem += v._2;
    } }
    //println("Total: " + mem + " bytes");
    
    //todo: add memory stats for Java runtime here as well to get overview
  }
}

/* SimpleApp.scala */
import org.apache.spark.SparkContext;
import org.apache.spark.SparkContext._;
import org.apache.spark.SparkConf;
import org.apache.spark.sql.{SQLContext, Row};

import org.apache.hadoop.io.Text;
import collection.JavaConversions._;

/* Idea:
 * Performa a join between the two amazon datasets we have (if possible)
 * and then run two applications against the join
 * show how both of them can accelerate each other thanks to the join
 */

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

object CheckCache {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("arjoin")
    val sc = new SparkContext(conf)
    val sq = new SQLContext(sc);
    PerfUtils.getFreeMemory(sc)
  }
}

object ARJoin {
  def main(args: Array[String]) {
    val conf = new SparkConf().setAppName("arjoin")
    val sc = new SparkContext(conf)
    val sq = new SQLContext(sc);
    PerfUtils.getFreeMemory(sc)

    var giftStart = System.currentTimeMillis
    println("Running gift calculation");
    run(sc, sq, true, false);
    var giftStop = System.currentTimeMillis

    PerfUtils.getFreeMemory(sc)
    var spouseStart = System.currentTimeMillis
    println("Running spouse calculation");
    run(sc, sq, false, true);
    var spouseStop = System.currentTimeMillis

    PerfUtils.getFreeMemory(sc)
    var bothStart = System.currentTimeMillis
    println("Running both calculation");
    run(sc, sq, true, true);
    var bothStop = System.currentTimeMillis

    println(s"Gifts took: ${giftStop - giftStart} ms");
    println(s"Spouses took: ${spouseStop - spouseStart} ms");
    println(s"Both took: ${bothStop - bothStart} ms");

    PerfUtils.getFreeMemory(sc)
  }

  def run(sc:SparkContext, sq:SQLContext, run_gifts:Boolean, run_spouses:Boolean){
    //val rankings = sc.textFile("hdfs:///user/spark/benchmark/amazon_reviews");
    val rankings = sq.read.json("hdfs:///user/spark/benchmark/amazon_reviews/reviews_a*.gz");
      //val numLines = rankings.count();
      //println("Total lines: %s".format(numLines))
    //rankings.printSchema();
    //sq.sql("SELECT avg( from 
    /* schema parsed by sql:
     root
	 |-- asin: string (nullable = true)
	 |-- helpful: array (nullable = true)
	 |    |-- element: long (containsNull = true)
	 |-- overall: double (nullable = true)
	 |-- reviewText: string (nullable = true)
	 |-- reviewTime: string (nullable = true)
	 |-- reviewerID: string (nullable = true)
	 |-- reviewerName: string (nullable = true)
	 |-- summary: string (nullable = true)
	 |-- unixReviewTime: long (nullable = true)
	*/
   val asins = rankings.rdd.groupBy( (r) => {
     r(0) //asin
   });
   asins.persist();

   /* two different tasks!! */
   /* both group by product id
    *   reviews by time of day analysis
    *   re-reviews from same user
    *   kinds of words that are used in the review
    *   gift?? does that change the review score?
    */

   /* gifts? */
  var gifts = asins.filter( (x:(_, Iterable[Row])) =>  // case(k:String, revs:Iterable[Row]) =>
  {
    x._2.map( _.getString(3).contains("gift") ).foldLeft(false)( _ || _ )
  })
  var spouse = asins.filter( (x:(_, Iterable[Row])) =>  // case(k:String, revs:Iterable[Row]) =>
  {
    x._2.map( x => x.getString(3).contains("husband") || x.getString(3).contains("wife") ).foldLeft(false)( _ || _ ) 
    //|| _.getString(3).contains("wife") 
  })

  var gifts_gby_count:Long = 0;
  if( run_gifts ){
    gifts_gby_count = gifts.count()
  }
  var spouse_gby_count:Long = 0;
  if (run_spouses){
    spouse_gby_count = spouse.count()
  }
  //var asin_gby_count = asins.count()

  println("gifts gby: %s".format(  gifts_gby_count  ));
  println("spouse gby: %s".format(  spouse_gby_count  ));
  //println("asin gby: %s".format( asin_gby_count ));
  PerfUtils.getFreeMemory(sc)
  }
}


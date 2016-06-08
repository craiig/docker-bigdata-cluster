import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.apache.spark.sql.Row


object benchKmeans {
  def main(args: Array[String]) {

    val conf       = new SparkConf().setAppName("K-means Benchmark")
    val sc         = new SparkContext(conf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    val json_file = "reviews_books_first_1000.json"

    // Create the DataFrame
    val df = sqlContext.read.json(json_file)

    val parsedData = df.map(t => Vectors.dense(
                              t.getAs[Double]("overall"),
                              t.getAs[String]("reviewText").length().toDouble,
                              t.getAs[Long]("unixReviewTime").toDouble
                                              )).cache()

    // Cluster the data into two classes using KMeans
    val numClusters   = 2
    val numIterations = 20
    val clusters      = KMeans.train(parsedData, numClusters, numIterations)

    // Evaluate clustering by computing Within Set Sum of Squared Errors
    val WSSSE = clusters.computeCost(parsedData)
      println("Within Set Sum of Squared Errors = " + WSSSE)

    // Save and load model
    clusters.save(sc, "myModelPath")
    val sameModel = KMeansModel.load(sc, "myModelPath")
  }
}

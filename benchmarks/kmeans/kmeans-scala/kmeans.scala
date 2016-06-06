import org.apache.spark.mllib.clustering.{KMeans, KMeansModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

object benchKmeans {
  def main(args: Array[String]) {

    val conf = new SparkConf().setAppName("K-means Benchmark")
    val sc   = new SparkContext(conf)

    // Load and parse the data
    val data       = sc.textFile("../../data/amazon_reviews/reviews_books_first_1000.json")
    val parsedData =  data.map(s => Vectors.dense(s.split(' ').map(_.toDouble))).cache()

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

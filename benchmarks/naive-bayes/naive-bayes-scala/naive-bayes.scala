import org.apache.spark.mllib.classification.{NaiveBayes, NaiveBayesModel}
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.apache.spark.sql.Row


object benchNaiveBayes {
  def main(args: Array[String]) {

    val conf       = new SparkConf().setAppName("Naive Bayes Benchmark")
    val sc         = new SparkContext(conf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    var json_file = "reviews_books_first_1000.json"
    if (args.length == 1) {
      json_file = args(0);
    }
    println("Reading from file: " + json_file);

    // Create the DataFrame
    val df = sqlContext.read.json(json_file)

    val parsedData = df.map(t =>
                            LabeledPoint(
                              t.getAs[Double]("overall"),
                              Vectors.dense(
                                t.getAs[String]("reviewText").length().toDouble,
                                t.getAs[Long]("unixReviewTime").toDouble
                              )
                            )
                           )


    // Split data into training (60%) and test (40%).
    val splits = parsedData.randomSplit(Array(0.6, 0.4), seed = 11L)
    val training = splits(0)
    val test = splits(1)

    val model = NaiveBayes.train(training, lambda = 1.0, modelType = "multinomial")

    val predictionAndLabel = test.map(p => (model.predict(p.features), p.label))
    val accuracy = 1.0 * predictionAndLabel.filter(x => x._1 == x._2).count() / test.count()

    // Save and load model
    // model.save(sc, "target/tmp/myNaiveBayesModel")
    // val sameModel = NaiveBayesModel.load(sc, "target/tmp/myNaiveBayesModel")

  }

}


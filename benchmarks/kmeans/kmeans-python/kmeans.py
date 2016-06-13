import sys
from pyspark.mllib.clustering import KMeans, KMeansModel
from pyspark import SparkContext
import json

# Load and parse the data
sc = SparkContext("", "Python K-Means Amazon Reviews")

# First arg must be the filename
filename = sys.argv[1]
data = sc.textFile(filename)
parsedData = data.map(lambda line: json.loads(line)).\
             map(lambda line: (float(line['overall']),
                               float(len(line['reviewText'])),
                               float(line['unixReviewTime'])))

# Build the model (cluster the data)
clusters = KMeans.train(parsedData, 2, maxIterations=10,
                        runs=10, initializationMode="random")


# Evaluate clustering by computing Within Set Sum of Squared Errors
WSSSE = clusters.computeCost(parsedData)
print("Within Set Sum of Squared Error = " + str(WSSSE))
print clusters.centers

# Save and load model
clusters.save(sc, "myModelPath")
sameModel = KMeansModel.load(sc, "myModelPath")

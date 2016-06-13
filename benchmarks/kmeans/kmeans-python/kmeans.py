from pyspark.mllib.clustering import KMeans, KMeansModel
# from numpy import array
from math import sqrt
from pyspark import SparkContext
import json

# Load and parse the data
sc = SparkContext("local", "Python K-Means Amazon Reviews")

data = sc.textFile('reviews_books_first_1000.json')
parsedData = data.map(lambda line: json.loads(line)).\
             map(lambda line: (line['overall'], len(line['reviewText'])))

# Build the model (cluster the data)
clusters = KMeans.train(parsedData, 2, maxIterations=10,
                        runs=10, initializationMode="random")


# Evaluate clustering by computing Within Set Sum of Squared Errors
def error(point):
    center = clusters.centers[clusters.predict(point)]
    return sqrt(sum([x**2 for x in (point - center)]))

WSSSE = parsedData.map(lambda point: error(point)).reduce(lambda x, y: x + y)
print("Within Set Sum of Squared Error = " + str(WSSSE))

# Save and load model
clusters.save(sc, "myModelPath")
sameModel = KMeansModel.load(sc, "myModelPath")

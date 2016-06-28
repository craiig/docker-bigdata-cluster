#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

"""
NaiveBayes Example.
"""
# from __future__ import print_function

from pyspark import SparkContext
# $example on$
from pyspark.mllib.classification import NaiveBayes
from pyspark.mllib.linalg import Vectors
from pyspark.mllib.regression import LabeledPoint


def getFeatures(content):
    features = {'sunglasses': 0, 'cheap': 1, 'free': 2, 'money': 3,
                'time': 4, 'person': 5, 'kind': 6, 'linux': 7,
                'rich': 8, 'peek': 9, 'curious': 10, 'charges': 11,
                'norco': 12, 'adderall': 13, 'limited': 14,
                'offer': 15, 'today': 16, 'price': 17, 'webcam': 18,
                'url': 19}
    result = [0 for _ in xrange(len(features))]
    for word in content.split():
        word = word.lower()
        if word in features:
            result[features[word]] = 1
    return Vectors.dense(result)

if __name__ == "__main__":

    sc = SparkContext(appName="PythonNaiveBayesExample-SpamFilter")

    # Get email labels
    # labels: {filename: isSpam (1 or 0)}
    labels = sc.textFile('CSDMC2010_SPAM/SPAMTrain.label').\
        map(lambda line: line.split()).\
        map(lambda (num, name): (name, int(num))).\
        collectAsMap()

    # Get email content
    # emails: [ (isSpam, content) ]
    emails = sc.wholeTextFiles('CSDMC2010_SPAM/TRAINING').\
        map(lambda (filename, content):
            (labels[filename.split('/')[-1]], content)).\
        map(lambda (isSpam, content):
            LabeledPoint(str(isSpam), getFeatures(content)))
    # print emails

    # Split data aproximately into training (60%) and test (40%)
    training, test = emails.randomSplit([0.6, 0.4], seed=9023)

    # Train a naive Bayes model.
    model = NaiveBayes.train(training, 1.0)

    # Make prediction and test accuracy.
    predictionAndLabel = test.map(
        lambda p: (model.predict(p.features), p.label))
    accuracy = 1.0 * predictionAndLabel.filter(
        lambda (x, v): x == v).count() / test.count()
    print '\n'*20, 'ACCURACY', accuracy

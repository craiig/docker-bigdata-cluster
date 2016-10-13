#!/usr/bin/env python

# reads stack frame dumps in the format:
# <stackId>; <stackId>; <stackId>; 
# ^ bottom              ^ top
#
# and outputs a summary with regards to jvm/hadoop/spark components

import sys, re
from collections import OrderedDict
from pprint import pprint
import json
import argparse

totals = OrderedDict()
total_lines = 0
unknown_totals = 0

# parse args to read file
parser = argparse.ArgumentParser(description='summarize stack traces into spark components')
parser.add_argument('--summarize', '-s', action='store_true')
parser.add_argument('--name', '-n')
args = parser.parse_args()

#overall goal with this classification is:
# classify based on the flow of the spark logic
# and not to attempt to group lower level functions together ->
# i.e. all gzip calls

for l in sys.stdin:
    cls = l #default classification is just the entire stack

    #breakdown reading a broadcast variable
    if re.search("org\.apache\.spark\.rdd\.HadoopRDD getJobConf", l, flags=re.IGNORECASE):
        cls = '(hadoop) getJobConf Broadcast'
    elif re.search("org.apache.spark.broadcast.Broadcast value", l, flags=re.IGNORECASE):
        cls = '(spark) Read Broadcast value'

    # possible to hit linerecordreader from outside putinblockmanager or getorcompute (why?)
    # because this the data was found in cache and so an iterator was returned to it
    elif re.search("org.apache.hadoop.fs", l, flags=re.IGNORECASE):
        cls = "(hadoop) org.apache.hadop.fs *"
    elif re.search("org.apache.hadoop.hdfs", l, flags=re.IGNORECASE):
        cls = "(hadoop) org.apache.hadoop.hdfs *"
    elif re.search("org.apache.hadoop.io.compress.DecompressorStream read", l, flags=re.IGNORECASE):
        cls = "(hadoop) decompressor) decompressorStream"
    elif re.search("org.apache.hadoop.mapred.LineRecordReader", l, flags=re.IGNORECASE):
        cls = '(hadoop) read record'
        # cls = '(hadoop) read record '+l
    elif re.search("org.apache.hadoop.io.Text toString", l, flags=re.IGNORECASE):
        cls = '(hadoop) deserialization) toString'
    elif re.search("java.lang.Thread run;org.apache.hadoop.hdfs.PeerCache", l, flags=re.IGNORECASE):
        cls = '(hadoop) hdfs peercache'
    elif re.search("java.lang.Thread run;org.apache.hadoop.net.unix.DomainSocketWatcher", l, flags=re.IGNORECASE):
        cls = "(hadoop) networking"
    elif re.search("^org.apache.hadoop.io.Text decode", l, flags=re.IGNORECASE):
        cls = "(hadoop) deserialization) text decode"

    # accumulo stacks
    elif re.search("org.apache.accumulo.core.client.mapreduce.AccumuloInputFormat", l, flags=re.IGNORECASE):
        cls = "(accumulo) AccumuloInputFormat "
    elif re.search("org.apache.accumulo.core.tabletserver", l, flags=re.IGNORECASE):
        cls = "(accumulo) tabletserver client " 
    elif re.search("org.apache.accumulo.fate.util.LoggingRunnable", l, flags=re.IGNORECASE):
        cls = "(accumulo) logging " 
    elif re.search("apache.accumulo.core.client.impl.ThriftScanner", l, flags=re.IGNORECASE):
        cls = "(accumulo) ThriftScanner "
    elif re.search("org.apache.accumulo.core.client.impl.ScannerIterator", l, flags=re.IGNORECASE):
        cls = "(accumulo) ThriftScanner "
    elif re.search("org.apache.accumulo.core.data..* toString", l, flags=re.IGNORECASE):
        cls = "(accumulo) toString "
    
    #serialization
    elif re.search("org.apache.spark.serializer.JavaSerializerInstance deserialize", l, flags=re.IGNORECASE):
        cls = '(spark deserialize) serializer deserialize'
        cls = '(spark deserialize) serializer deserialize '+l
    elif re.search("org.apache.spark.serializer.DeserializationStream.*java.io.BufferedInputStream", l, flags=re.IGNORECASE):
        cls = '(spark deserialize) java.io.BufferedInputStream '+l
    elif re.search("org.apache.spark.serializer.DeserializationStream", l, flags=re.IGNORECASE):
        cls = '(spark deserialize) org.apache.spark.serializer.DeserializationStream'
        cls = '(spark deserialize) org.apache.spark.serializer.DeserializationStream ' +l
    elif re.search("org.apache.spark.serializer.JavaSerializer newInstance;", l, flags=re.IGNORECASE):
        cls = '(spark serialize) spark.serializer new'
    elif re.search("org.apache.spark.serializer.SerializationStream", l, flags=re.IGNORECASE):
        cls = '(spark serialize) org.apache.spark.serializer.SerializationStream.*'

    # parts of reading data and writing it into the cache:
    # this happens as part of getOrCompute, so we classify it first
    # elif re.search("putInBlockManager.*org.apache.spark.serializer.SerializationStream", l, flags=re.IGNORECASE):
        # cls = 'putInBlockManager -> org.apache.spark.serializer.SerializationStream'
    # elif re.search("putInBlockManager.*org.apache.spark.storage.MemoryStore unrollSafely", l, flags=re.IGNORECASE):
        # cls = 'putInBlockManager -> unrollSafely' #iterators and cleanup
    # elif re.search("putInBlockManager.*putArray", l, flags=re.IGNORECASE):
        # cls = 'putInBlockManager -> putArray' #storing data after unrolling
    elif re.search("org.apache.spark.CacheManager putInBlockManager", l, flags=re.IGNORECASE):
        cls = '(spark cache write) putInBlockManager'
        # cls = '(spark) putInBlockManager ' + l

    #break down get or compute into reading or computing from the various soures
    elif re.search("getOrCompute.*org.apache.spark.storage.BlockManager getLocal", l, flags=re.IGNORECASE):
        cls = '(spark) getLocal'
    elif re.search("getOrCompute.*org.apache.spark.storage.BlockManager getRemote", l, flags=re.IGNORECASE):
        cls = '(spark) getRemote'

    #rdd's doing work
    elif re.search("getOrCompute.org.apache.spark.rdd.RDD computeOrReadCheckpoint", l, flags=re.IGNORECASE):
        cls = '(spark) compute rdd'
    elif re.search("org.apache.spark.CacheManager getOrCompute", l, flags=re.IGNORECASE):
        cls = '(spark) getOrCompute'

    #hadoop ipc
    elif re.search("^org.apache.hadoop.ipc.Client\$Connection run", l, flags=re.IGNORECASE):
        cls = '(hdfs) org.apache.hadoop.ipc.Client*'


    # called by RDD.count()
    elif re.search("org.apache.spark.util.Utils\$ getIteratorSize", l, flags=re.IGNORECASE):
        cls = "(spark) count()"

    #more general
    elif re.search("org.apache.spark.network", l, flags=re.IGNORECASE):
        cls = '(spark networking) org.apache.spark.network.*'
    elif re.search("io.netty", l, flags=re.IGNORECASE):
        cls = '(spark networking) io.netty.*'
    elif re.search("org.jboss.netty", l, flags=re.IGNORECASE):
        cls = '(spark networking) org.jboss.netty.*'
    elif re.search("akka.actor", l, flags=re.IGNORECASE):
        cls = '(spark networking) akka.actor'
    elif re.search("ava.lang.Thread run;sun.net.www.http.KeepAliveCache", l, flags=re.IGNORECASE):
        cls = '(spark networking) http.KeepAliveCache'

    # all other stack traces that are part of running a task
    elif re.search("org.apache.spark.executor.Executor\$TaskRunner run", l, flags=re.IGNORECASE):
        cls = '(spark) spark.Executor$TaskRunner run'
    elif re.search("java.lang.ref.Finalizer\$FinalizerThread", l, flags=re.IGNORECASE):
        cls = "(java) java.lang.ref.Finalizer$FinalizerThread"
    elif re.search("ForkJoinTask doExec;akka.dispatch", l, flags=re.IGNORECASE):
        cls = "(spark networking) akka.dispatch"

    elif re.search("org.spark-project.", l, flags=re.IGNORECASE):
        cls = '(spark) other'
    

    #low level java concurrency
    elif re.search("java.util.concurrent.FutureTask run", l, flags=re.IGNORECASE):
        cls = "(java) java.util.concurrent.FutureTask run"
    elif re.search("java.util.concurrent.ThreadPoolExecutor runWorker", l, flags=re.IGNORECASE):
        cls = "(java) java.util.concurrent.ThreadPoolExecutor runWorker"
    elif re.search("scala.concurrent.forkjoin.ForkJoinWorkerThread run", l, flags=re.IGNORECASE):
        cls = "(java) scala.concurrent.forkjoin.ForkJoinWorkerThread run"

    #zookeeper
    elif re.search("org.apache.zookeeper.ClientCnxn", l, flags=re.IGNORECASE):
        cls = "(accumulo) org.apache.zookeeper.ClientCnxn"

    #java reference handler thread?
    elif re.search("java.lang.ref.Reference\$ReferenceHandler", l, flags=re.IGNORECASE):
        cls = '(java) java.lang.ref.Reference$ReferenceHandler'
    elif re.search("java.lang.Thread run;", l, flags=re.IGNORECASE):
        #!!! should be the very last entry
        cls = '(java) java.lang.Thread run'

    #make sure to not count the not java samples
    if re.search("AGCT Unknown", l, flags=re.IGNORECASE):
        unknown_totals = unknown_totals + 1

    #translate low level breakdown into higher level subsystems
    if args.summarize:
        m = re.match("\((.*?)\).*", cls)
        if m:
            # print cls
            # print m.group(1)
            # print "**"
            cls = m.group(1)

    count = totals.get(cls,0)
    totals[cls] = (count+1)
    total_lines = total_lines + 1

#order by samples
totals = OrderedDict(sorted(totals.items(), key=lambda x: x[1])) 
#order by name
# totals = OrderedDict(sorted(totals.items(), key=lambda x: x[0])) 
# print json.dumps(totals, indent=4);
for (k,v) in totals.items():
    out = [k,v]
    if args.name:
        out = [args.name] + out

    out = map(lambda x: str(x).strip(), out)
    print ",".join(out)

# print >>sys.stderr, ""
# print >>sys.stderr, "samples parsed: %s" % (total_lines)
# print >>sys.stderr, "unknown samples: %s" % (unknown_totals)
# print >>sys.stderr, "java samples: %s" % (total_lines - unknown_totals)

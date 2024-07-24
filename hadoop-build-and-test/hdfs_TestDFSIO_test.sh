#!/usr/bin/env bash

set -eu

if [ "$("$HADOOP_HOME"/bin/hdfs dfs -test -d /benchmarks/TestDFSIO)" == 0 ]; then
    "$HADOOP_HOME"/bin/hdfs dfs -rm -r /benchmarks/TestDFSIO
fi

"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar TestDFSIO -write -nrFiles 5 -fileSize 1000

"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar TestDFSIO -read -nrFiles 5 -fileSize 1000

"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar TestDFSIO -clean

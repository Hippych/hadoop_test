#!/usr/bin/env bash

set -eu

if [ "$("$HADOOP_HOME"/bin/hdfs dfs -test -d /benchmarks/testLoadSpace)" == 0 ]; then
    "$HADOOP_HOME"/bin/hdfs dfs -rm -r /benchmarks/testLoadSpace
fi

if [ "$(/usr/bin/test -d "$HOME"/benchmarks/testLoadSpace)" == 0 ]; then
    /bin/rm -rf "$HOME"/benchmarks/testLoadSpace
else
    /bin/mkdir -p "$HOME"/benchmarks/testLoadSpace
fi

"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar NNstructureGenerator \
        -outDir benchmarks/testLoadSpace \
        -maxDepth 10 \
        -minWidth 1 \
        -maxWidth 7 \
        -numOfFiles 100 \
&& \
"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar NNdataGenerator \
        -inDir "$HOME"/benchmarks/testLoadSpace \
        -root /benchmarks/testLoadSpace \
&& \
"$HADOOP_HOME"/bin/yarn jar "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.0-tests.jar NNloadGenerator \
        -root /benchmarks/testLoadSpace \
        -elapsedTime 120 \
&& \
"$HADOOP_HOME"/bin/hdfs dfs -rm -r /benchmarks/testLoadSpace \
/bin/rm -rf "$HOME"/benchmarks/testLoadSpace

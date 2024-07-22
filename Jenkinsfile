pipeline {
 
    agent any
 
    environment {
        GIT_URL = "https://github.com/apache/hadoop"
        GIT_TAG = "rel/release-3.4.0"
        CONTAINER_ID = "docker ps --format 'CONTAINER ID : {{.ID}} | Image:  {{.Image}}' | grep 'hadoop-build' | awk '{print \$4}'"
        CORE_SITE = "'<property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property><property><name>hadoop.http.staticuser.user</name><value>hadoop</value></property></configuration>'"
        HDFS_SITE = "'<property><name>dfs.replication</name><value>1</value></property><property><name>dfs.name.dir</name><value>file:///hadoop/hdfs/namenode</value></property><property><name>dfs.data.dir</name><value>file:///hadoop/hdfs/datanode</value></property><property><name>dfs.permissions</name><value>true</value></property></configuration>'"
        YARN_SITE = "'<property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property><property><name>yarn.nodemanager.env-whitelist</name><value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value></property></configuration>'"
        MAPRED = "'<property><name>mapreduce.framework.name</name><value>yarn</value></property><property><name>mapreduce.application.classpath</name><value>\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:\$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value></property></configuration>'"
        HADOOP_ENV = "'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64'"
        SED_XML = "'</configuration>'"

    }
    stages {
        
        stage ("checkout git") {
            steps {
                
                cleanWs()
                  
                checkout ([
                    $class: 'GitSCM',
                    branches: [[name: "${GIT_TAG}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [[$class: 'CleanCheckout']],
                    submoduleCfg: [],
                    userRemoteConfigs: [[url: "${GIT_URL}"]]
                    ])
           }
        }
        
        stage ("build docker container and hadoop") {
            
            steps {
                
                sh """
                    /bin/sed -i 's|-i -t|--tty|' start-build-env.sh
                """

                sh 'sh ./start-build-env.sh mvn -Dparallel=all -DthreadCount=4 package -Pdist,native -DskipTests -Dtar -Dmaven.javadoc.skip=true'
            }
        }
        
        stage ("deploy") {
            
            steps {
                sshagent(credentials: ['root-hadoop-node-key']) {
                
                sh """
                    scp -o StrictHostKeyChecking=no ./hadoop-dist/target/hadoop-3.4.0.tar.gz root@192.168.0.156:/opt/  
                    ssh root@192.168.0.156 " \
                    /bin/mkdir -p \
                    /opt/hadoop \
                    /hadoop/hdfs/{namenode,datanode}; \
                    /bin/tar -xzvf /opt/hadoop-3.4.0.tar.gz -C /opt/hadoop --strip-components=1; \
                    /bin/rm /opt/hadoop-3.4.0.tar.gz; \
                    /bin/sed -i 's|"${SED_XML}"|"${CORE_SITE}"|' /opt/hadoop/etc/hadoop/core-site.xml; \
                    /bin/sed -i 's|"${SED_XML}"|"${HDFS_SITE}"|' /opt/hadoop/etc/hadoop/hdfs-site.xml; \
                    /bin/sed -i 's|"${SED_XML}"|"${YARN_SITE}"|' /opt/hadoop/etc/hadoop/yarn-site.xml; \
                    /bin/sed -i 's|"${SED_XML}"|"${MAPRED}"|' /opt/hadoop/etc/hadoop/mapred-site.xml; \
                    /bin/echo '"${HADOOP_ENV}"' >> /opt/hadoop/etc/hadoop/hadoop-env.sh; \
                    /bin/chown -R hadoop:hadoop \
                    /opt/hadoop \
                    /hadoop; \
                    /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs datanode -format; \
                    /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs namenode -format; \
                    /usr/bin/sudo -u hadoop /opt/hadoop/sbin/start-dfs.sh; \
                    /usr/bin/sudo -u hadoop /opt/hadoop/sbin/start-yarn.sh"
                """
                   
                }
            }
        }
        
        stage ("test") {
            
            steps {
                sshagent(credentials: ['root-hadoop-node-key']) {
                    
                    sh """
                        ssh root@192.168.0.156 " \
                        /usr/bin/sudo -u hadoop /bin/mkdir /hadoop/test_files; \
                        /usr/bin/sudo -u hadoop /usr/bin/fallocate -l 1G /hadoop/test_files/test.file.1Gb; \
                        /usr/bin/sudo -u hadoop /usr/bin/fallocate -l 500M /hadoop/test_files/test.file.500Mb; \
                        /usr/bin/sudo -u hadoop /usr/bin/fallocate -l 100M /hadoop/test_files/test.file.100Mb; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -mkdir /test_in; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -put /hadoop/test_files/test.file.1Gb /test_in; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -put /hadoop/test_files/test.file.500Mb /test_in; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -put /hadoop/test_files/test.file.100Mb /; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -ls /test_in/; \
                        /usr/bin/sudo -u hadoop /opt/hadoop/bin/hdfs dfs -ls /; \
                        /bin/rm -r /hadoop/test_files"
                    """
                }
            }
        }
    }
        
}

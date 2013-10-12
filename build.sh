#!/bin/bash


### ELASTICSEARCH KOREAN ANALYSIS PLUGIN
cd elasticsearch-analysis-korean

ES_VERSION=0.90.2

if [ -n $ES_HOME ]
then
  export ES_HOME=$HOME/elasticsearch-$ES_VERSION
fi

#clean and compile maven package of elasticsearch korean analysis plugin
mvn clean package

#check plugin version
PLUGIN_NEW=$(find ./target -iregex '.*jar' -printf '%f\n')
PLUGIN_OLD=$(find $ES_HOME/plugins/analysis-korean -iregex '.*jar' -printf '%f\n')

if [ -z "$PLUGIN_OLD" ] && [ "$PLUGIN_NEW" != "$PLUGIN_OLD" ]
then
  #remove old plugin and copy new one
  if [ -n "$PLUGIN_OLD" ]
  then
    rm $ES_HOME/plugins/analysis-korean/$PLUGIN_OLD -f
  fi
  cp ./target/$PLUGIN_NEW $ES_HOME/plugins/analysis-korean/

  #restart elasticsearch
  $ES_HOME/bin/service/elasticsearch restart
else
  echo "Korean Analysis plugin is up to date."
fi

cd ..

### WALL
cd infinitewall
export PATH="$HOME/bin":"$HOME/bin/scala/bin":"`pwd`/Play20":$PATH
set
# clean
play clean
# compile
play compile

# kill previous server process
if [ -e RUNNING_PID ]; then
	kill `cat RUNNING_PID`
fi
# DO it again in more general form for verification
#ps aux | grep play | awk '{ print $2 }' | xargs -I {} kill {}

if [ -e infinitewall.h2.db ]; then
	echo "H2 database already exists."
else
	echo "Creating symbolic links to H2 database"
	if [ -n $INFINITEWALL_H2_PATH ]; then
		ln -s $INFINITEWALL_H2_PATH/infinitewall.h2.db infinitewall.h2.db
		ln -s $INFINITEWALL_H2_PATH/infinitewall.trace.db infinitewall.trace.db
		ln -s $INFINITEWALL_H2_PATH/infinitewall.lock.db infinitewall.lock.db
	fi
fi

# use existing files
if [ $USER == "jenkins_slave" ]; then
	if [ ! -d "public/files" ]; then
    ln -s /home/jenkins_slave/infinitewall_custom/public/files public/files
  fi
fi

# run tests
#play test

# start the server
play stage
BUILD_ID=0 nohup target/start -Dhttp.port=9000 -Dhttps.port=9443 -DapplyEvolutions.default=false > log.log 2>&1 &

# for more detailed configuration:
#target/start -Dconfig.file=/full/path/to/conf/application-prod.conf

sleep 10

# apply any possible evolution scripts
#curl -X GET localhost:9000/@evolutions/apply/default > /dev/null

#!/bin/bash


### ELASTICSEARCH KOREAN ANALYSIS PLUGIN
cd elasticsearch-analysis-korean

ES_VERSION=0.90.2

if [ -n $ES_HOME ]
then
  export ES_HOME=$HOME/elasticsearch-$ES_VERSION
fi

TARGET_PATH="target/universal/stage"

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

# kill previous server process
if [ -e $TARGET_PATH/RUNNING_PID ]; then
	kill `cat $TARGET_PATH/RUNNING_PID`
fi


# clean
play clean
# compile
play compile


# DO it again in more general form for verification
#ps aux | grep play | awk '{ print $2 }' | xargs -I {} kill {}


# run tests
#play test

# create stage
play stage


if [ $USER == "jenkins_slave" ]; then
# copy files
#	if [ -e $TARGET_PATH/infinitewall.h2.db ]; then
#		echo "H2 database already exists."
#	else
#		echo "Creating symbolic links to H2 database"
#		if [ -n $INFINITEWALL_H2_PATH ]; then
#			ln -s $INFINITEWALL_H2_PATH/infinitewall.h2.db infinitewall.h2.db
#			ln -s $INFINITEWALL_H2_PATH/infinitewall.trace.db infinitewall.trace.db
#			ln -s $INFINITEWALL_H2_PATH/infinitewall.lock.db infinitewall.lock.db
#		fi
#	fi

# use existing h2 database (Dev)
  if [ ! -e "$TARGET_PATH/activatedwall.h2.db" ]; then
    ln -s `pwd`/activatedwall.h2.db $TARGET_PATH/activatedwall.h2.db
    ln -s `pwd`/activatedwall.trace.db $TARGET_PATH/activatedwall.trace.db
  	if [ -e `pwd`/activatedwall.lock.db ]; then
    	rm -f $TARGET_PATH/activatedwall.lock.db
		ln -s `pwd`/activatedwall.lock.db $TARGET_PATH/activatedwall.lock.db
	fi
  fi


# use existing public/* files

  if [ ! -d "$TARGET_PATH/public/files" ]; then
    mkdir -p $TARGET_PATH/public
    ln -s /home/jenkins_slave/infinitewall/public/files `pwd`/$TARGET_PATH/public/files
  fi
fi



# start the server

BUILD_ID=0 nohup $TARGET_PATH/bin/infinitewall -Dhttp.port=9000 -Dhttps.port=9443 -Dhttps.keyStore=conf/infinitwall_com.jks -Dhttps.keyStorePassword="infinitwall302" -Dhttps.cipherSuites="EECDH+ECDSA+AESGCM,EECDH+aRSA+AESGCM,EECDH+ECDSA+SHA384,EECDH+ECDSA+SHA256,EECDH+aRSA+SHA384,EECDH+aRSA+SHA256,EECDH+aRSA+RC4,EECDH,EDH+aRSA,RC4,!aNULL,!eNULL,!LOW,!3DES,!MD5,!EXP,!PSK,!SRP,!DSS,+RC4,RC4" -DapplyEvolutions.default=false -Dsecuresocial.ssl=true > log.log 2>&1 &

# for more detailed configuration:
#target/start -Dconfig.file=/full/path/to/conf/application-prod.conf

sleep 10

# apply any possible evolution scripts
#curl -X GET localhost:9000/@evolutions/apply/default > /dev/null

#!/bin/bash

# build (optionally) play itself
if [ $USER == "jenkins_slave" ]; then
	export PATH="$HOME/bin":"$HOME/bin/scala/bin":"`pwd`/Play20":$PATH

	cd Play20/framework
	set
	./build publish-local
	cd -
fi

cd infinitewall

# compile
play compile

# kill previous server process
if [ -e RUNNING_PID ]; then
	kill `cat RUNNING_PID`
fi
# DO it again in more general form for verification
ps aux | grep play | awk '{ print $2 }' | xargs -I {} kill {}

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
	rm -rf public/files
	ln -s /home/jenkins_slave/infinitewall/public/files public/files
fi

# run tests
play test

# start the server
play stage
BUILD_ID=0 nohup target/start -Dhttp.port=9000 > log.log 2>&1 &

# for more detailed configuration:
#target/start -Dconfig.file=/full/path/to/conf/application-prod.conf

sleep 10

# apply any possible evolution scripts
curl -X GET localhost:9000/@evolutions/apply/default > /dev/null

# run phantomjs integration tests
for jsfile in test/integration/phantomjs/*.js
do
	phantomjs $jsfile
done


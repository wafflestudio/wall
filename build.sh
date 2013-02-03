#!/bin/bash

if [ $USER == "jenkins_slave" ]; then
	export PATH="$HOME/bin":"$HOME/bin/scala/bin":"`pwd`/Play20":$PATH

	cd Play20/framework
	set
	./build publish-local
	cd -
fi

cd infinitewall
play compile
play test
for jsfile in test/integration/phantomjs/*.js
do
	phantomjs $jsfile
done
exit 1

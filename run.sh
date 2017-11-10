#! /bin/sh
export ROOT=$(cd `dirname $0`; pwd)
export DAEMON=false

while getopts "DK" arg
do
	case $arg in
		D)
			export DAEMON=true
			;;
		K)
			kill `cat $ROOT/run/skynet.pid`
			exit 0;
			;;
	esac
done

$ROOT/skynet/skynet $ROOT/config
# $ROOT/skynet/skynet $ROOT/examples/config.socket
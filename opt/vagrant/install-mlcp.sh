#! /bin/sh
echo "running $0 $@"

yum -y install zip unzip
yum -y install java-1.8.0-openjdk-devel

if [ "$1" -eq "8" ]; then
    echo "Installing MLCP 1.3-1..."
	if [ ! -d /opt/mlcp-Hadoop2-1.3-1 ]; then
	    cd /opt && unzip /space/software/mlcp-Hadoop2-1.3-1-bin.zip
	fi
	if [ ! -h /usr/local/mlcp ]; then
	    cd /usr/local && ln -s /opt/mlcp-Hadoop2-1.3-1 mlcp
	fi
else
    echo "Installing MLCP 1.2-3..."
	if [ ! -d /opt/mlcp-Hadoop2-1.2-3 ]; then
	    cd /opt && unzip /space/software/mlcp-Hadoop2-1.2-3-bin.zip
	fi
	if [ ! -h /usr/local/mlcp ]; then
	    cd /usr/local && ln -s /opt/mlcp-Hadoop2-1.2-3 mlcp
	fi
fi

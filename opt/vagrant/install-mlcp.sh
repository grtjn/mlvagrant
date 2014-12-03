#! /bin/sh
echo "running $0 $@"

yum -y install zip unzip

if [ ! -d /opt/mlcp-Hadoop2-1.2-3 ]; then
    cd /opt && unzip /space/software/mlcp-Hadoop2-1.2-3-bin.zip
    if [ -h /usr/local/mlcp ]; then
        unlink /usr/local/mlcp
    fi
fi
if [ ! -h /usr/local/mlcp ]; then
    cd /usr/local && ln -s /opt/mlcp-Hadoop2-1.2-3 mlcp
fi
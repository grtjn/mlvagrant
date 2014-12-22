#! /bin/sh
echo "running $0 $@"

# Install git
yum -y install tomcat

chkconfig --levels 2345 tomcat on

service tomcat start

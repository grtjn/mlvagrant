#! /bin/sh

INSTALL_TOMCAT=false
INSTALL_GIT=false
INSTALL_NODE=false
source /project/root/project.properties

echo "running $0 $@"
sudo /opt/vagrant/restore-yum-cache.sh
sudo /opt/vagrant/install-ml-CentOS.sh $2
sudo /opt/vagrant/setup-ml-master.sh $1 $2 $3
sudo /opt/vagrant/install-mlcp.sh $2
sudo /opt/vagrant/install-user.sh $4
if [ INSTALL_NODE == true ]; then
    sudo /opt/vagrant/install-node.sh
fi
if [ INSTALL_GIT == true ]; then
    sudo /opt/vagrant/setup-git.sh $4
fi
if [ INSTALL_TOMCAT == true ]; then
    sudo /opt/vagrant/setup-tomcat.sh
fi
sudo /opt/vagrant/backup-yum-cache.sh

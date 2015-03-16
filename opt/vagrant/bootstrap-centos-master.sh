#! /bin/sh
echo "running $0 $@"
sudo /opt/vagrant/restore-yum-cache.sh
sudo /opt/vagrant/install-ml-CentOS.sh $2
sudo /opt/vagrant/setup-ml-master.sh $1 $2 $3
sudo /opt/vagrant/install-node.sh
sudo /opt/vagrant/install-mlcp.sh $2
sudo /opt/vagrant/install-user.sh $4
sudo /opt/vagrant/setup-git.sh $4
sudo /opt/vagrant/setup-tomcat.sh
sudo /opt/vagrant/backup-yum-cache.sh

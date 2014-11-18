#! /bin/sh
echo "running $0 $@"
sudo /opt/vagrant/install-ml-CentOS.sh $2
sudo /opt/vagrant/setup-ml-master.sh $1 $2
sudo /opt/vagrant/install-node.sh
sudo /opt/vagrant/install-mlcp.sh
sudo /opt/vagrant/setup-git.sh $3

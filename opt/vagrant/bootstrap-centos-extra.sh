#! /bin/sh
echo "running $0 $@"
sudo /opt/vagrant/install-ml-CentOS.sh $2
sudo /opt/vagrant/setup-ml-extra.sh $@

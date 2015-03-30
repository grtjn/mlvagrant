#! /bin/sh
echo "running $0 $@"
sudo /opt/vagrant/restore-yum-cache.sh
sudo /opt/vagrant/install-ml-centos.sh $2
sudo /opt/vagrant/setup-ml-extra.sh $@
sudo /opt/vagrant/backup-yum-cache.sh
sudo /opt/vagrant/set-env-vars.sh

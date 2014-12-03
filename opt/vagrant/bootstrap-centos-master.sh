#! /bin/sh
echo "running $0 $@"
if [ -d /opt/vagrant ]; then
    cd /opt/vagrant
fi
sudo restore-yum-cache.sh
sudo install-ml-CentOS.sh $2
sudo setup-ml-master.sh $1 $2
sudo install-node.sh
sudo install-mlcp.sh
sudo install-user.sh $3
sudo setup-git.sh $3
sudo backup-yum-cache.sh

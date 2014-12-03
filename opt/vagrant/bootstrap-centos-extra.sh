#! /bin/sh
echo "running $0 $@"
if [ -d /opt/vagrant ]; then
    cd /opt/vagrant
fi
sudo restore-yum-cache.sh
sudo install-ml-CentOS.sh $2
sudo setup-ml-extra.sh $@
sudo backup-yum-cache.sh

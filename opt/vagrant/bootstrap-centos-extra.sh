#! /bin/sh
echo "running $0 $@"

# Convert all property keys to lowercase and store to tmp file to be sourced.
sed 's/.*=/\L&/' /vagrant/project.properties > /tmp/mlvagrant.project.properties

# Run the installers
sudo /opt/vagrant/restore-yum-cache.sh
sudo /opt/vagrant/install-ml-centos.sh
sudo /opt/vagrant/setup-ml-extra.sh $@
sudo /opt/vagrant/backup-yum-cache.sh

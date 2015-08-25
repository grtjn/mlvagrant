#! /bin/sh
echo "running $0 $@"

# Convert all property keys to lowercase and store to tmp file to be sourced.
if [ -d /vagrant ]; then
  sed 's/.*=/\L&/' /vagrant/project.properties > /tmp/$4.project.properties
else
  printf "ml_version=$2\n" > /tmp/$4.project.properties
fi

# Run the installers
sudo /opt/vagrant/restore-yum-cache.sh
sudo /opt/vagrant/install-ml-centos.sh $2
sudo /opt/vagrant/setup-ml-extra.sh $@
sudo /opt/vagrant/backup-yum-cache.sh

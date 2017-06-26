#! /bin/sh
echo "running $0 $@"

# Convert all property keys to lowercase and store to tmp file to be sourced.
if [ -f /vagrant/project.properties ]; then
  sed 's/.*=/\L&/' /vagrant/project.properties > /tmp/$4.project.properties
elif [ -f project.properties ]; then
  sed 's/.*=/\L&/' project.properties > /tmp/$4.project.properties
elif [ -f /opt/vagrant/project.properties ]; then
  sed 's/.*=/\L&/' /opt/vagrant/project.properties > /tmp/$4.project.properties
else
  printf "ml_version=$2\n" > /tmp/$4.project.properties
fi

# Run the installers.
sudo /opt/vagrant/remove-ml.sh $5
sudo /opt/vagrant/install-ml-centos.sh $4
if [ "$5" == "true" ]; then
  sudo /opt/vagrant/setup-ml-extra.sh $@
fi
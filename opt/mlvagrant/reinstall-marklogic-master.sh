#! /bin/sh
echo "running $0 $@"

# Convert all property keys to lowercase and store to tmp file to be sourced.
if [ -f /vagrant/project.properties ]; then
  sed 's/.*=/\L&/' /vagrant/project.properties > /tmp/$4.project.properties
elif [ -f project.properties ]; then
  sed 's/.*=/\L&/' project.properties > /tmp/$4.project.properties
elif [ -f /opt/mlvagrant/project.properties ]; then
  sed 's/.*=/\L&/' /opt/mlvagrant/project.properties > /tmp/$4.project.properties
else
  printf "ml_version=$2\n" > /tmp/$4.project.properties
fi

yum makecache fast

# Run the installers.
sudo /opt/mlvagrant/remove-ml.sh $5
sudo /opt/mlvagrant/install-ml-centos.sh $4
if [ "$5" == "true" ]; then
  sudo /opt/mlvagrant/setup-ml-master.sh $1 $2 $3
fi

# Also rerun MLCP installation
sudo rm -f /usr/local/mlcp
sudo /opt/mlvagrant/install-mlcp.sh $4

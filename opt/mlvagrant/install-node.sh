#! /bin/sh
echo "running $0 $@"

# Defaults
install_nodejs=true
install_nodejs_lts=true
install_ruby=true

# Load the normalized project properties.
source /tmp/$1.project.properties

if [ $install_nodejs == "true" ]; then

  # make sure nodejs is not pre-installed
  yum remove -y nodejs npm

  # curl, as well as epel-release necessary to install nodejs/npm on CentOS 5, no harm otherwise
  yum -y install curl epel-release

  # get correct nodejs installation
  if [ $install_nodejs_lts == "true" ]; then
    curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
  else
    curl --silent --location https://rpm.nodesource.com/setup | bash -
  fi

  # install nodejs + potentially necessary build tools
  yum -y install gcc-c++ make nodejs

fi

if [ $install_ruby == "true" ]; then
  if [ hash ruby 2> /dev/null ]; then
    echo 'Ruby is already installed'
  else
    yum -y install ruby
  fi
fi

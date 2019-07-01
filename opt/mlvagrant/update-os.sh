#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# Defaults
update_os=false
install_dev_tools=false

# Load the normalized project properties.
source /tmp/$1.project.properties

yum makecache fast

if [ $update_os == "true" ]; then
  yum -y update
fi
if [ $install_dev_tools == "true" ]; then
  if [[ $os == *"7."* ]]; then
    yum groups mark convert 2> /dev/null # suppress annoying message of missing groups file, we are generating it!
    yum groups mark install "Development Tools"
  fi
  yum -y groupinstall "Development Tools"
fi

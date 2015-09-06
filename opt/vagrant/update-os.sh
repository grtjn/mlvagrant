#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

yum -y update
if [[ $os == *"7."* ]]; then
  yum groups mark convert 2> /dev/null # suppress annoying message of missing groups file, we are generating it!
  yum groups mark install "Development Tools"
fi
yum -y groupinstall "Development Tools"

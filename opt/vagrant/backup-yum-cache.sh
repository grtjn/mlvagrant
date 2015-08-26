#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# no need for caching installs on demo servers
if [ -d /vagrant ]; then
  if [[ $os == *"7."* ]]; then
    cp -R /var/cache/yum /space/software/yum-centos7
  else
    cp -R /var/cache/yum /space/software/
  fi
fi

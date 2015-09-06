#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# no need for caching installs on demo servers
if [ ! -d /var/cache/yum ]; then
  mkdir /var/cache/yum
fi
if [ -d /vagrant ]; then
  if [[ $os == *"7."* ]]; then
    if [ -d /space/software/centos7 ]; then
      cp -R /space/software/centos7/yum /var/cache/
    fi
  elif [[ $os == *"5."* ]]; then
    if [ -d /space/software/centos5 ]; then
      cp -R /space/software/centos5/yum /var/cache/
    fi
  else
    # assume centos6
    if [ -d /space/software/centos6 ]; then
      cp -R /space/software/centos6/yum /var/cache/
    # backwards compat with old backup location
    elif [ -d /space/software/yum ]; then
      cp -R /space/software/yum /var/cache/
    fi
  fi
  
  sed -i '/keepcache/ s/0/1/' /etc/yum.conf
fi

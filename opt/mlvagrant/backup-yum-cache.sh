#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# no need for caching installs on demo servers
if [ -d /vagrant ]; then
  if [[ $os == *"7."* ]]; then
    if [ ! -d /space/software/centos7 ]; then
      mkdir -p /space/software/centos7
    fi
    cp -R /var/cache/yum /space/software/centos7/
  elif [[ $os == *"5."* ]]; then
    if [ ! -d /space/software/centos5 ]; then
      mkdir -p /space/software/centos5
    fi
    cp -R /var/cache/yum /space/software/centos5/
  else
    # assume centos6
    if [ ! -d /space/software/centos6 ]; then
      mkdir -p /space/software/centos6
    fi
    cp -R /var/cache/yum /space/software/centos6/
  fi
fi

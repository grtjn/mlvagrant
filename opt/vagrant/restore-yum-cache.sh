#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# no need for caching installs on demo servers
if [ -d /vagrant ]; then
  if [[ $os == *"7."* ]]; then
    cp -R /space/software/yum-centos7 /var/cache/yum
  else
    cp -R /space/software/yum /var/cache/
  fi
  
  sed -i '/keepcache/ s/0/1/' /etc/yum.conf
fi

if [[ $os == *"7."* ]]; then
  rpm --import https://fedoraproject.org/static/352C64E5.txt
  rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
else
  rpm --import https://fedoraproject.org/static/0608B895.txt
  rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
fi

yum -y update
if [[ $os == *"7."* ]]; then
  yum groups mark install "Development Tools"
  yum groups mark convert "Development Tools"
fi
yum -y groupinstall "Development Tools"

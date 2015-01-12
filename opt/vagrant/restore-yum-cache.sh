#! /bin/sh
echo "running $0 $@"

if [ -d /vagrant ]; then
  # no need for caching installs on demo servers
  cp -R /space/software/yum /var/cache/
  
  sed -i '/keepcache/ s/0/1/' /etc/yum.conf
fi
#! /bin/sh
echo "running $0 $@"

cp -R /space/software/yum /var/cache/

sed -i '/keepcache/ s/0/1/' /etc/yum.conf

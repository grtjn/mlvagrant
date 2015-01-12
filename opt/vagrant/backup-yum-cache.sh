#! /bin/sh
echo "running $0 $@"

if [ -d /vagrant ]; then
  # no need for caching installs on demo servers
  cp -R /var/cache/yum /space/software/
fi

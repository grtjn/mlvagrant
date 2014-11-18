#! /bin/sh
echo "running $0 $@"

rpm --import https://fedoraproject.org/static/0608B895.txt
rpm -Uvh http://download-i2.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum -y install nodejs npm --enablerepo=epel
if [ ! hash bower 2>/dev/null]; then
    npm install -g bower
fi
if [ ! hash gulp 2>/dev/null]; then
    npm install -g gulp
fi
if [ ! hash forever 2>/dev/null]; then
    npm install -g forever
fi

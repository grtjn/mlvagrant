#! /bin/sh
echo "running $0 $@"

rpm --import https://fedoraproject.org/static/0608B895.txt
rpm -Uvh http://download-i2.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
yum -y install nodejs npm --enablerepo=epel

if hash bower 2>/dev/null; then
  echo 'Bower is already installed'
else
  npm install -g bower
fi

if hash gulp 2>/dev/null; then
  echo 'Gulp is already installed'
else
  npm install -g gulp
fi

if hash forever 2>/dev/null; then
  echo 'Forever is already installed'
else
  npm install -g forever
fi

if hash ruby 2>/dev/null; then
  echo 'Ruby is already installed'
else
  yum -y install ruby
fi

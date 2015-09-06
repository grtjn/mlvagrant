#! /bin/sh
echo "running $0 $@"

yum -y install curl epel-release # epel-release necessary to install nodejs/npm on CentOS 5, and no harm otherwise
curl --silent --location https://rpm.nodesource.com/setup | bash -
yum -y install gcc-c++ make nodejs

if [ hash bower 2> /dev/null ]; then
  echo 'Bower is already installed'
else
  npm -q install -g bower
fi

if [ hash gulp 2> /dev/null ]; then
  echo 'Gulp is already installed'
else
  npm -q install -g gulp
fi

if [ hash forever 2> /dev/null ]; then
  echo 'Forever is already installed'
else
  npm -q install -g forever
fi

if [ hash ruby 2> /dev/null ]; then
  echo 'Ruby is already installed'
else
  yum -y install ruby
fi

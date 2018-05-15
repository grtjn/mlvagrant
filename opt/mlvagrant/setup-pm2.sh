#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# Defaults
install_nodejs=true
install_pm2=true

# Load the normalized project properties.
source /tmp/$1.project.properties

if [ $install_pm2 == "true" ] && [ $install_nodejs == "true" ]; then
  # PM2 will need git for deployment
  if [[ $os == *"7."* ]]; then
    # install git v2 if possible
    rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-1.noarch.rpm && yum -y install git
  else
    yum -y install git
  fi

  # Install PM2
  npm install -g pm2

  # create pm2 user for Vagrant vm's
  if [ -d /vagrant ] && [ ! id -u pm2 > /dev/null 2>&1 ]; then
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
    /usr/sbin/useradd -m -p $pass pm2
  fi

  # Launch PM2 service, if possible
  if [ id -u pm2 > /dev/null 2>&1 ] && [ -d /home/pm2 ]; then
    # Setup PM2 init service scripts
    if [[ $os == *"7."* ]]; then
      # use systemd on CentOS 7
      pm2 startup systemd -u pm2 --hp /home/pm2 --no-daemon
      /bin/systemctl start pm2-pm2
    else
      # use service scripts on CentOS 6-
      pm2 startup centos -u pm2 --hp /home/pm2 --no-daemon
      /sbin/service pm2-init.sh start
    fi
  else
    echo "WARN: pm2 user doesn't exist yet, could not init nor launch PM2 service!"
    # well, technically, one could run it with root, but that is not recommended
  fi

  # Make sure a projects folder exists, used for deployment
  mkdir -p /space/projects
  # change permissions to allow remote deployment
  if [ -d /vagrant ] && [ id -u $1 > /dev/null 2>&1 ]; then
    chown $1:sshuser /space/projects
  else
    # creation of users is limited on demo servers
    chown $USER:sshuser /space/projects
  fi
  chmod g+rw /space/projects

elif [ $install_pm2 == "true" ]; then

  echo "FAIL: NodeJS is required for PM2"

fi


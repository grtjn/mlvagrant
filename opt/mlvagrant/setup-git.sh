#! /bin/sh
echo "running $0 $@"

# Defaults
install_git=true
install_git_project=true

# Load the normalized project properties.
source /tmp/$1.project.properties

os=`cat /etc/redhat-release`

if [ $install_git == "true" ]; then
  # Install git
  if [[ $os == *"7."* ]]; then
    yum install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-1.noarch.rpm
  else
    yum install http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
  fi
  yum -y install git
fi

# older style git projects, local git repo with hooks
if [ $install_git_project == "true" ]; then

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

  # create a local git repo
  mkdir -p /space/projects/$1.git

  # initialize the git repo
  cd /space/projects/$1.git
  if [ ! -f HEAD ]; then
    git --bare init
  fi
  if [ ! -f hooks/post-receive ]; then
    printf "#!/bin/sh\nin=\$(cat)\nbranch=\${in##*/}\nGIT_WORK_TREE=/space/projects/$1.live git checkout -f \$branch\n" > hooks/post-receive
    chmod 755 hooks/post-receive
  fi

  # create a project deploy dir
  mkdir -p /space/projects/$1.live

  # change permissions to allow remote deployment
  cd /space/projects
  if [ -d /vagrant ]; then
    chown -R $1:sshuser $1.git
    chown -R $1:sshuser $1.live
  else
    # creation of users is limited on demo servers
    chown -R $USER:sshuser $1.git
    chown -R $USER:sshuser $1.live
  fi
  chmod -R g+rw $1.git
  chmod -R g+rw $1.live
  chmod g+s $1.git
  chmod g+s $1.live
fi

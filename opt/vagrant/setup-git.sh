#! /bin/sh
echo "running $0 $@"

# Install git
yum -y install git

# create a local git repo
mkdir -p /space/projects/$1.git

# initialize the git repo
cd /space/projects/$1.git
if [ ! -f HEAD ]; then
  git --bare init
fi
if [ ! -f hooks/post-receive ]; then
  printf "#!/bin/sh\nin=\$(cat)\nbranch=\${in##*/}\nGIT_WORK_TREE=/space/projects/$1.live git checkout -f \$branch\nchown -R :sshuser /space/projects/$1.live\nchmod -R g+rw /space/projects/$1.live\n" > hooks/post-receive
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

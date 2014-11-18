#! /bin/sh
echo "running $0 $@"

yum -y install git

mkdir -p /space/projects/$1.git
mkdir -p /space/projects/$1.live
cd /space/projects/$1.git
if [ ! -f HEAD ]; then
    chmod g+s .
    git --bare init
fi
if [ ! -f hooks/post-receive ]; then
    printf "#!/bin/sh\nGIT_WORK_TREE=/space/projects/$1.live git checkout -f master\n" > hooks/post-receive
    chmod 755 hooks/post-receive
fi
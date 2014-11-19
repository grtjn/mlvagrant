#! /bin/sh
echo "running $0 $@"

groupadd -r sshuser
pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
useradd -m -G sshuser -U -p $pass $1

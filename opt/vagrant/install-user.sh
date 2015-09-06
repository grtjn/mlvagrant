#! /bin/sh
echo "running $0 $@"

if [ -d /vagrant ]; then
  # creation of goups and users is limited on demo servers
  /usr/sbin/groupadd -r sshuser
  pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
  /usr/sbin/useradd -m -G sshuser -p $pass $1
fi

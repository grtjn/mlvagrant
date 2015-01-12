#! /bin/sh
echo "running $0 $@"

if [ -d /vagrant ]; then
  # creation of goups and users is limited on demo servers
  groupadd -r sshuser
  pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
  useradd -m -G sshuser -U -p $pass $1
fi

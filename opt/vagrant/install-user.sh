#! /bin/sh
echo "running $0 $@"

if [ -d /vagrant ]; then
  # Defaults
  install_git_project=true

  # Load the normalized project properties.
  source /tmp/$1.project.properties

  if [ $install_git_project == "true" ]; then
    # creation of goups and users is limited on demo servers
    /usr/sbin/groupadd -r sshuser
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
    /usr/sbin/useradd -m -G sshuser -p $pass $1
  fi
fi

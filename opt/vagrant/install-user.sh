#! /bin/sh
echo "running $0 $@"

# creation of goups and users is limited on demo servers
if [ -d /vagrant ]; then
  # Defaults
  install_git_project=true

  # Load the normalized project properties.
  source /tmp/$1.project.properties

  /usr/sbin/groupadd -r sshuser

  if [ $install_git_project == "true" ]; then
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $1)
    /usr/sbin/useradd -m -G sshuser -p $pass $1
  fi
fi

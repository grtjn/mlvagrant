#! /bin/sh
echo "running $0 $@"

# Defaults
install_httpd=true
install_https=true

# Load the normalized project properties.
source /tmp/$1.project.properties

if [ $install_httpd == "true" ]; then

  # httpd likely pre-installed on demo servers, but run this anyhow
  yum -y install httpd
  /sbin/chkconfig --levels 2345 httpd on
  /sbin/setsebool -P httpd_can_network_connect 1
fi

if [ $install_https == "true" ]; then
  yum -y install mod_ssl openssl
  yum -y install openldap-clients # command-line utils
  echo "Note: check the README for using HTTPS with httpd!"
fi

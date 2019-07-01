#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# Defaults
install_tomcat=false
launch_tomcat=false

# Load the normalized project properties.
source /tmp/$1.project.properties

if [ $install_tomcat == "true" ]; then

  # tomcat likely pre-installed on demo servers, but run this anyhow
  if [[ $os == *"7."* ]]; then
    yum -y install tomcat
  elif [[ $os == *"5."* ]]; then
    yum -y install tomcat5
  else
    yum -y install tomcat6
  fi

  if [ $launch_tomcat == "true" ]; then

    # tomcat likely pre-installed on demo servers, but run this anyhow
    if [[ $os == *"7."* ]]; then
      /sbin/chkconfig --levels 2345 tomcat on
      /sbin/service tomcat start
    elif [[ $os == *"5."* ]]; then
      /sbin/chkconfig --levels 2345 tomcat5 on
      /sbin/service tomcat5 start
    else
      /sbin/chkconfig --levels 2345 tomcat6 on
      /sbin/service tomcat6 start
    fi

    echo "Note: consider running Tomcat behind a firewall if you intend to keep it open!"
  fi

fi

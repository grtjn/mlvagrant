#! /bin/sh
echo "running $0 $@"

os=`cat /etc/redhat-release`

# tomcat likely pre-installed on demo servers, but run this anyhow
if [[ $os == *"7."* ]]; then
  yum -y install tomcat
  /sbin/chkconfig --levels 2345 tomcat on
  /sbin/service tomcat start
elif [[ $os == *"5."* ]]; then
  yum -y install tomcat5
  /sbin/chkconfig --levels 2345 tomcat5 on
  /sbin/service tomcat5 start
else
  yum -y install tomcat6
  /sbin/chkconfig --levels 2345 tomcat6 on
  /sbin/service tomcat6 start
fi

echo "Note: consider running Tomcat behind a firewall if you intend to keep it open!"

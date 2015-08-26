#! /bin/sh
echo "running $0 $@"

# Load the normalized project properties.
source /tmp/$1.project.properties

yum -y install zip unzip
yum -y install java-1.8.0-openjdk-devel

# Determine installer to use.
if [ -n "${mlcp_installer}" ]; then
  installer=${mlcp_installer} 
elif [ "${ml_version}" -eq "8" ]; then
  installer=mlcp-1.3-3-bin.zip
elif [ "${ml_version}" -eq "7" ]; then
  installer=mlcp-Hadoop2-1.2-4-bin.zip
else
  installer=mlcp-Hadoop2-1.0-5-bin.zip
fi

echo "Installing MLCP using $installer ..."
install_dir=$(echo $installer | sed -e "s/-bin.zip//g")
if [ ! -d /opt/$install_dir ]; then
  cd /opt && unzip "/space/software/$installer"
fi
if [ ! -h /usr/local/mlcp ]; then
  echo "setting sym-link: /opt/$install_dir for mlcp"
  cd /usr/local && ln -s "/opt/$install_dir" mlcp
fi

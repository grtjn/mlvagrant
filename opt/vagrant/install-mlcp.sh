#! /bin/sh
echo "running $0 $@"

# Defaults
ml_version=8
install_zip=true
install_java=true
install_mlcp=true

# Load the normalized project properties.
source /tmp/$1.project.properties

# Zip/unzip not required for MLCP (provided through Java)
if [ $install_zip == "true" ]; then
  yum -y install zip unzip
elif [ $install_mlcp == "true" ]; then
  # but installation does require unzip
  yum -y install unzip
fi

if [ $install_mlcp == "true" ]; then
  # Java required for MLCP
  yum -y install java-1.8.0-openjdk-devel

  # Determine installer to use.
  if [ -n "${mlcp_installer}" ]; then
    installer=${mlcp_installer} 
  elif [ $ml_version == "8" ]; then
    installer=mlcp-8.0.6.4-bin.zip
  elif [ $ml_version == "9" ]; then
    installer=mlcp-9.0.1-bin.zip
  elif [ $ml_version == "7" ]; then
    installer=mlcp-7.0-6.4-bin.zip
  else
    installer=mlcp-1.3-3-bin.zip
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

elif [ $install_java == "true" ]; then
  yum -y install java-1.8.0-openjdk-devel
fi

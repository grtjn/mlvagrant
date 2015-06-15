#! /bin/sh
echo "running $0 $@"

yum -y install zip unzip
yum -y install java

if [ "$1" -eq "8" ]; then
    echo "Installing MLCP 1.3-2..."
  if [ ! -d /opt/mlcp-1.3-3 ]; then
      cd /opt && unzip /space/software/mlcp-1.3-3-bin.zip
  fi
  if [ ! -h /usr/local/mlcp ]; then
      cd /usr/local && ln -s /opt/mlcp-1.3-3 mlcp
  fi
elif [ "$1" -eq "7" ]; then
    echo "Installing MLCP 1.2-4..."
  if [ ! -d /opt/mlcp-Hadoop2-1.2-4 ]; then
      cd /opt && unzip /space/software/mlcp-Hadoop2-1.2-4-bin.zip
  fi
  if [ ! -h /usr/local/mlcp ]; then
      cd /usr/local && ln -s /opt/mlcp-Hadoop2-1.2-4 mlcp
  fi
else
  echo "Installing MLCP 1.0-5..."
  if [ ! -d /opt/mlcp-Hadoop2-1.0-5 ]; then
      cd /opt && unzip /space/software/mlcp-Hadoop2-1.0-5-bin.zip
  fi
  if [ ! -h /usr/local/mlcp ]; then
      cd /usr/local && ln -s /opt/mlcp-Hadoop2-1.0-5 mlcp
  fi
fi

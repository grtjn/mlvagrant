#! /bin/sh
echo "running $0 $@"

# Defaults
ml_version=8

# Load the normalized project properties.
source /tmp/$1.project.properties

# TODO: Apply recommended page settings
#echo 320 > /proc/sys/vm/nr_hugepages
#echo "transparent_hugepage=never" >> /etc/grub.conf

# Install dependencies required by MarkLogic
yum -y install glibc.i686 gdb.x86_64 redhat-lsb.x86_64 cyrus-sasl cyrus-sasl-lib cyrus-sasl-md5

if [ -f /lib64/libsasl2.so.3 ]; then
    ln -s /lib64/libsasl2.so.3 /lib64/libsasl2.so.2
fi

if [ -d /vagrant ]; then
  # Install dependencies required by Vagrant hostmanager
  yum -y install avahi avahi-tools nss-mdns nmap

  # Make sure services are started
  service messagebus restart
  service avahi-daemon start
fi

# Prepare folders for MarkLogic
mkdir -p /space/var/opt/MarkLogic
sudo chown daemon:daemon /space/var/opt/MarkLogic
if [ ! -h /var/opt/MarkLogic ]; then
    cd /var/opt && sudo ln -s /space/var/opt/MarkLogic MarkLogic
fi

# Determine the MarkLogic installer to use
if [ -n "${ml_installer}" ]; then
    installer=${ml_installer}
elif [ "${ml_version}" = "5" ]; then
    installer="MarkLogic-5.0-6.1.x86_64.rpm"
elif [ "${ml_version}" = "6" ]; then
    installer="MarkLogic-6.0-6.x86_64.rpm"
elif [ "${ml_version}" = "8" ]; then
    installer="MarkLogic-8.0-3.x86_64.rpm"
else
    installer="MarkLogic-7.0-5.2.x86_64.rpm"
fi

# Run MarkLogic installer
echo "Installing ML using /space/software/$installer ..."
rpm -i "/space/software/$installer"

# Make sure MarkLogic is started
service MarkLogic restart
echo "Waiting for server restart.."
sleep 5

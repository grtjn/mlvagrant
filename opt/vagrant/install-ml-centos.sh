#! /bin/sh
echo "running $0 $@"

# Load the normalized project properties.
source /tmp/mlvagrant.project.properties

# TODO: Apply recommended page settings
#echo 320 > /proc/sys/vm/nr_hugepages
#echo "transparent_hugepage=never" >> /etc/grub.conf

# Install dependencies required by MarkLogic
yum -y install glibc.i686 gdb.x86_64 redhat-lsb.x86_64

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
elif [ "${ml_version}" -eq "5" ]; then
    installer="MarkLogic-5.0-6.1.x86_64.rpm"
elif [ "${ml_version}" -eq "6" ]; then
    installer="MarkLogic-6.0-5.3.x86_64.rpm"
elif [ "${ml_version}" -eq "8" ]; then
    installer="MarkLogic-8.0-3.x86_64.rpm"
else
    installer="MarkLogic-7.0-5.1.x86_64.rpm"
fi

# Run MarkLogic installer
echo "Installing ML using /space/software/$installer ..."
rpm -i "/space/software/$installer"

# Make sure MarkLogic is started
service MarkLogic restart
echo "Waiting for server restart.."
sleep 5

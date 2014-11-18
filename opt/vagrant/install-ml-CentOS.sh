#! /bin/sh
echo "running $0 $@"

# Install dependencies required by MarkLogic and hostmanager
yum -y install glibc.i686 gdb.x86_64 redhat-lsb.x86_64 avahi avahi-tools nss-mdns nmap

# Make sure services are started
service messagebus restart
service avahi-daemon start

# Prepare folders for MarkLogic
mkdir -p /space/var/opt/MarkLogic
sudo chown daemon:daemon /space/var/opt/MarkLogic
if [ ! -h /var/opt/MarkLogic ]; then
    cd /var/opt && sudo ln -s /space/var/opt/MarkLogic MarkLogic
fi

# Run MarkLogic installer
if [ "$1" -eq "5" ]; then
    echo "Installing ML 5..."
    rpm -i /space/software/MarkLogic-5.0-6.1.x86_64.rpm
elif [ "$1" -eq "6" ]; then
    echo "Installing ML 6..."
    rpm -i /space/software/MarkLogic-6.0-5.3.x86_64.rpm
elif [ "$1" -eq "8" ]; then
    echo "Installing ML 8..."
    rpm -i /space/software/MarkLogic-8.0-20140809.x86_64.rpm
else
    echo "Installing ML 7..."
    rpm -i /space/software/MarkLogic-7.0-4.x86_64.rpm
fi

# Make sure MarkLogic is started
service MarkLogic restart
echo "Waiting for server restart.."
sleep 5

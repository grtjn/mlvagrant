# mlvagrant

Scripts for bootstrapping a local MarkLogic cluster for development purposes using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

Key features:

- Easy creation of VirtualBox VMs
- Works on Windows, MacOS, and Linux
- Uses pre-built CentOS Vagrant base boxes
- Supports MarkLogic 5 up to 9
- Supports CentOS 5.11 up to 7.2
- Automatic setup of cluster
- Also installs MLCP, Java, NodeJS, Ruby, etc
- Highly configurable
- Scripts can be used for other servers as well

## Description

By default these scripts create 3 'grtjn/centos-6.7' Vagrant VMs, running in VirtualBox. The names and ips will be recorded in /etc/hosts of host and VMs with use of vagrant-hostmanager. MarkLogic (including dependencies) will be installed on all three vms, and bootstrapped to form a cluster. The OS will be fully updated initially, and "Development Tools" installed as well. Zip/Unzip, Java, MLCP, Nodejs, Bower, Gulp, Forever, Ruby, Git, and Tomcat will be installed, and configured. A bare git repository will be prepared in /space/projects. All automatically with just a few commands.

Each VM takes roughly 2.5Gb. The VM template, together with 3 VMs will take about 10Gb of disk space. In addition, each VM that is launched will claim 2Gb of RAM, and 2 CPU cores. Make sure you have sufficient resources!

Special credits to [@peetkes](https://github.com/peetkes) and [@miguelrgonzalez](https://github.com/miguelrgonzalez) for giving me a head start with this. Thanks to anyone else that has provided help or feedback!

Note: this project used to depend on chef/centos boxes, but they are no longer available. They have been 'moved' to bento, which only published latest release of each major version. I have recovered the chef base boxes from my local Vagrant cache, and republished on Atlas with my personal account: https://atlas.hashicorp.com/grtjn. I'll be using base boxes published there from now on.

## Getting started

You first need to download and install prerequisites and mlvagrant itself:

- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  - When using VirtualBox 5.1, make sure to use latest baseboxes, e.g. those for CentOS 6.8 and 7.2
- Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
- Install the [vagrant-hostmanager](https://github.com/smdahlen/vagrant-hostmanager) plugin:
  - `vagrant plugin install vagrant-hostmanager`
- If a proxy is required to access the external network, install the [vagrant-proxyconf](https://github.com/tmatilai/vagrant-proxyconf) plugin:
  - `vagrant plugin install vagrant-proxyconf`
- To optionally verify and fix VBox Guest Additions, install the [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) plugin:
  - `vagrant plugin install vagrant-vbguest`
- Create /space/software (**For Windows**: `c:\space\software`):
  - `sudo mkdir -p /space/software`
- Make sure Vagrant has write access to that folder:
  - `sudo chmod 777 /space/software`
- Download [MarkLogic 8.0-6 for CentOS](http://developer.marklogic.com/products) (login required)
- Download [MLCP 8.0-6 binaries](http://developer.marklogic.com/download/binaries/mlcp/mlcp-8.0.6-bin.zip)
- Move MarkLogic rpm, and MLCP zip to /space/software (no need to unzip MLCP!)
- Download mlvagrant:
  - `git clone https://github.com/grtjn/mlvagrant.git`
  - or pull down one of its release zips
- Create /opt/vagrant (**For Windows**: `c:\opt\vagrant`), if it doesn't exist yet:
  - `sudo mkdir -p /opt/vagrant`
- Make sure Vagrant has read/exec access to that dir:
  - `sudo chmod 755 /opt/vagrant`
- Copy mlvagrant/opt/vagrant to /opt/vagrant

**IMPORTANT:**

You will also need to get hold of a valid license key. Put the license key info in the appropriate ml license properties file in /opt/vagrant. You will need an Enterprise (Developer) license for setting up clusters. For project-specific licenses, copy these files next to project.properties first, and edit them there.

Above steps need to taken only once. For every project you wish to create VMs, you simply take these steps:

- Create a new project folder (anywhere you like) with a short name without spaces ('vgtest' for instance)
- Copy mlvagrant/project/Vagrantfile to that folder
- Copy mlvagrant/project/project.properties to that folder
- Open a Terminal or command-line in that folder, and run:
  - `vagrant up --no-provision` (may take a while depending on bandwidth, particularly first time)
  - `vagrant provision` (may take a while, enter sudo password when asked, to allow changing /etc/hosts)

That is all that is necessary to create a fully-prepared 3-node MarkLogic cluster running on CentOS 6.5 VMs. It takes the name of the project folder as prefix for the host names, to make running projects in parallel easier. If you ran the above in a folder called 'vgtest', it will have created three nodes with the names:

- vgtest-ml1 (cluster master)
- vgtest-ml2
- vgtest-ml3

To gain ssh access to the first, you do:

- `vagrant ssh vgtest-ml1`

To take one host down you do:

- `vagrant halt vgtest-ml2`

To take down all you do:

- `vagrant halt`

To destroy all VMs (maybe to recreate them from scratch):

- `vagrant destroy`

## Configuration options

The `project.properties` file contains various settings, amongst others:

- `nr_hosts`, defaults to 3
- `ml_version`, defaults to '8'

The minimum number of hosts is 1, the maximum is limited mostly by the local resources you have available. Each vm will take 2.5Gb of disk space, and by default (also in the Vagrantfile) takes 2Gb of ram, and 2 CPU cores.

Note: although you can technically create a cluster of just 2 nodes, 3 nodes is required for proper fail-over. The cluster needs a quorum to vote if a host should be excluded.

The ml_version is used in the `install-ml-centos.sh` script to select the appropriate installer. Code is in place to install versions 5, 6, 7, and 8. The install-ml script refers to rpm by exact name, which includes subversion number, and patch level. Feel free to change it locally to match the exact version you prefer to install.

For the full list of settings see below..

### project_name
Project name - defaults to current directory name

### vm_name
VM naming pattern - defaults to {project_name}-ml{i}, also allowed: {ml_version}

**IMPORTANT: DON'T CHANGE ONCE YOU HAVE CREATED THE VM'S!!**

### vm_version
CentOS base VM version - defaults to 6.7, allowed: 5.11/6.5/6.6/6.7/6.8/7.0/7.1/7.2

Note: CentOS 5(.11) does not support MarkLogic 8
Note: MarkLogic 9 requires CentOS 7

### ml_version
Major MarkLogic release to install - defaults to 8, allowed: 5,6,7,8,9 (installers need to be present)

### nr_hosts
Number of hosts in the cluster - defaults to 3, minimum for failover support

### master_memory
Memory assigned to master node in cluster (first vm) - defaults to 2048

Note: MarkLogic 9 EA3 requires at least 4Gb of memory.

### master_cpus
Number of cpus assigned to master node in cluster (first vm) - defaults to 2

### slave_memory
Memory assigned to each slave node in cluster - defaults to same as master_memory

Note: MarkLogic 9 EA3 requires at least 4Gb of memory.

### slave_cpus
Number of cpus assigned to each slave node in cluster - defaults to same as master_cpus

### public_network
Name of public_network to use in Vagrant, for instance "en0: Wi-Fi (AirPort)" - defaults to ""

Note: enabling this makes your VMs accessible from outside, beware of security leaks

### priv_net_ip
Assign dedicated private IP to master node - slaves get same ip + i

### net_proxy
URL for a network proxy for FTP, HTTP, and HTTPS requests

Use of this setting requires installation of the `vagrant-proxyconf` plugin

### no_proxy
Hostnames or IP addresses that do not require use of the network proxy

### shared_folder_host/shared_folder_guest
Mount an extra folder from host on vm - project dir is automatically shared as /vagrant

### ml_installer
Override hard-coded MarkLogic installers (file is searched in /space/software, or c:\space\software\ on Windows)

### mlcp_installer
Override hard-coded MLCP installers (file is searched in /space/software, or c:\space\software\ on Windows)

### update_os
Run full OS updates - defaults to false

Note: doing this with CentOS 6.5 or 7.0 will take it up to the very latest minor release (6.7+ resp 7.2+)

### install_dev_tools
Install group "Development tools" - defaults to false

### install_zip
Install zip/unzip - defaults to true

Note: Zip/unzip **not** required for MLCP (provided through Java)

### install_java
Install Java - defaults to true

Note: necessary for MLCP
Note: installs JDK 8 currently

### install_mlcp
Install MarkLogic Content Pump - defaults to true

Note: installs an MLCP version that matches ml_version, unless an explicit mlcp_installer was specified

### install_nodejs
Install Node.js, npm, bower, gulp, forever (globally) - defaults to true

## install_ruby
Install Ruby - default to true

Note: Ruby is mostly already installed on CentOS, this is just to be certain

### install_git
Install Git command-line tools - defaults to true

### install_git_project
Initializes a bare Git repository under /space/projects, along with a user named {project_name} to use it

### install_pm2
Install PM2 NodeJs Process Manager, for running NodeJs services - defaults to true

### install_httpd
Install and enable HTTPD service - defaults to true

Note: HTTPD is mostly already installed on CentOS, this is just to be certain

### install_https
Install modules and tools for SSL/HTTPS - defaults to true

Note: HTTPD needs to be configured properly to enable HTTPS in there. See [README](#using-https-with-httpd) for details.

### install_tomcat
Install Tomcat, and enable the service - defaults to true

Note: Tomcat could be pre-installed, but usually isn't enabled by default. This will make sure it is installed, and enabled.
Note: on CentOS 5 you get Tomcat 5 (tomcat5), on CentOS 6 you get Tomcat 6 (tomcat6), on CentOS 7 you get Tomcat 7 (tomcat)

## Fixing IP issues with public_network

The earlier version of mlvagrant was using public_network, and that will likely reappear as option soon. Handing out of IPs in that case depends on the external DHCP of the network you happen to be connected with. If you are running on a laptop, and take it elsewhere, your laptop, and public_network VMs will get new IPs. At that moment the hosts tables become outdated. You can fix that with a simple command though:

- vagrant hostmanager

That will go over all VMs, get its current IPs, and update the hosts tables on host and all VMs.

## Scaling cluster size up or down

Scaling up or down is not too big an issue, just make sure you follow below steps accurately:

To scale up:

- vi project.properties, increase nr_hosts
- vagrant status, make note of names of not-created VMs
- vagrant up --no-provision {names of 'not-created' VMs}
- vagrant host-manager (will run across all VMs and host to update hosts tables with new VMs)
- vagrant provision {names of 'not-created' VMs}

To scale down:

- vagrant status, make note of last VM name
- go to Admin UI on last vm (http://lastvmname:8001/)
- click on host details of that host, select Leave (you will need to move data, and remove all forests from that host first)
- vagrant destroy {lastvmname}
- vi project.properties, decrease nr_hosts setting

Note: you can scale down multiple hosts, but make sure to remove VMs from last to first. VM names are calculated by incrementing from 1 to nr_hosts. So, better not to leave gaps.

## Fixing license issues

If you don't provide a valid license upfront, the slave nodes likely won't be able connect to the master. Installation of MarkLogic 5 likely fails alltogether. You will need to open Admin UI on the master node (the first VM), apply a valid license, and then restart MarkLogic on all VMs. The lazy way to do the latter is to simply halt all VMs, and bring them up again (`vagrant halt ; vagrant up`)

Note: the correct procedure is to install valid licenses on all slave nodes as well. Open Admin UI via those hosts, and apply a license there as well.

## Pushing source code with git

A local git repository with a post-receive hook is initialized for you, together with a user-account for it. All you need to do to push any git repository onto the server is (assuming project name 'vgtest'):

- `git remote add vm vgtest@vgtest-ml1:/space/projects/vgtest.git`
- `git push vm`

The name of the user is derived from the folder name. The password is initialized to equal the user name, but can be changed if desired through:

- `vagrant ssh vgtest-ml1`
- `sudo passwd vgtest`

## Using bootstrap script without Vagrant

The bootstrap scripts contain a few safeguards that should allow running it outside (ML)Vagrant as well. I have used them on a fair number of internal demo-servers with success, also to create fully operational clusters in just a few steps. The procedure is a little different, but will save you a lot of manual typing:

-	Open an SSH connection to each server, create the folders for installers and scripts, and change ownership to yourself:
  - sudo mkdir -p /space/software
  - sudo mkdir -p /opt/vagrant
  - sudo chown $USER:sshuser /space/software
  - sudo chown $USER:sshuser /opt/vagrant
- Download the relevant ML and MLCP installers from http://developer.marklogic.com to your local machine.
- Download the mlvagrant file from github (git clone or download the release zip)
- Upload installers, and scripts to the first server using scp:
  - scp Downloads/MarkLogic-8.0-5.x86_64.rpm <node1 name/ip>:/space/software/
  - scp Downloads/mlcp-8.0-5-bin.zip <node1 name/ip>:/space/software/
  - scp <mlvagrant project dir>/opt/vagrant/* <node1 name/ip>:/opt/vagrant/
- On first server create files /opt/vagrant/bootstrap-node1.sh, /opt/vagrant/bootstrap-node2.sh, /opt/vagrant/bootstrap-node3.sh, .. (one for each server)
- Note: there is a bootstrap-server.sh script that you could take as example.
- Make them executable: chmod +x /opt/vagrant/*.sh
- The first should contain:

```bash
#! /bin/sh
echo "running $0 $@"
./bootstrap-centos-master.sh -v 8 <node1 name/ip> <projectname>
```

- Subsequent ones should contain:

```bash
#! /bin/sh
echo "running $0 $@"
./bootstrap-centos-extra.sh -v 8 <node1 name/ip> <nodeN name/ip> <projectname>
```

- Note: myproject can be any name, try to keep it short though
- From first server 'forward' installers and scripts to all others using scp:
  - scp /space/software/MarkLogic-8.0-6.x86_64.rpm <nodeN name/ip>:/space/software/
  - scp /space/software/mlcp-8.0.6-bin.zip <nodeN name/ip>:/space/software/
  - scp /opt/vagrant/* <nodeN name/ip>:/opt/vagrant/

Next, initiate MarkLogic bootstrapping on every machine, one by one. This will also by default install MLCP, Java, Git, NodeJS, and other useful tools, and make the MarkLogic instances join together in a cluster:

- On the first server:
  - cd /opt/vagrant/
  - ./bootstrap-node1.sh
  - wait till it finished (may take several minutes, this part requires internet access)
  - Note: a few steps might throw warnings or errors, but as long as next step succeeds, continue
  - Open http://<node1 name/ip>:8001/ (MarkLogic Admin UI)
  - Verify if host name of first node is correct, meaning that other hosts must be able to find this host using whatever is specified as host name (can be IP, just a name, or a full DNS name). If necessary add names to /etc/hosts on each server to make them find each other. That is essential for setting up the cluster.
- Repeat for subsequent nodes, with the appropriate bootstrap script. You should see a new host appear in the MarkLogic Admin UI each time, check host name of each newly added host as you go.
- Finally, as a good practice: create a personalized admin account (user with your name, and admin role), and preferably a second one for someone else.
- Check if you can login with that into the Admin ui, and then consider removing the admin/admin account (not required, but good practice as well)

Congratulations, you should have a working cluster. Now you can start deploying your MarkLogic applications on it!

## Using HTTPS with HTTPD

To be able to use HTTPS in HTTPD, you need mod_ssl and openssl libraries. Both are installed by mlvagrant by default.

Next to that, you will need a properly signed certificate. Your local IT department will likely be able to help with that. Here a general description of the practical steps required: https://wiki.centos.org/HowTos/Https#head-37cd1f5c67d362756f09313cd758bef48407c325 (section 2).

Once there, you can start configuring HTTPD for using HTTPS. You can do that per VirtualHost, as described here: https://wiki.centos.org/HowTos/Https#head-35299da4f7078eeba5f5f62b0222acc8c5f2db5f (section 3), but you can also consider configuring the SSLCert* properties on global level in `/etc/httpd/conf.d/ssl.conf`.

While in there, also consider applying a more strict SSL policy:

```
SSLCipherSuite ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!TLSv1.0:!SSLv3
SSLProtocol ALL -SSLv2 -SSLv3
```

Once you have applied those SSL properties globally, you only need to add `SSLEngine on` to the appropriate VirtualHosts in `/etc/httpd/conf/httpd.conf`.

Restart HTTPD to apply config changes.

## PM2 NodeJS Process Manager

MlVagrant now also includes setting up PM2. It is recommended to create an appropriate pm2 user upfront for running the pm2 service 'globally'. The following installation guide give an impression of how PM2 can be used to both deploy and run project code on a server: https://github.com/marklogic/slush-marklogic-node/blob/master/app/templates/INSTALL.mdown#deploying-to-a-server

## Fixing issues with Guest Additions

If you install the vagrant-vbguest plugin, you will get notifications like these below if it notices a mismatch between your local installation of VirtualBox, and the Guest Additions on the vm:

```
==> ml9-ml1: Checking for guest additions in VM...
    ml9-ml1: The guest additions on this VM do not match the installed version of
    ml9-ml1: VirtualBox! In most cases this is fine, but in rare cases it can
    ml9-ml1: prevent things such as shared folders from working properly. If you see
    ml9-ml1: shared folder errors, please make sure the guest additions within the
    ml9-ml1: virtual machine match the version of VirtualBox you have installed on
    ml9-ml1: your host and reload your VM.
    ml9-ml1: 
    ml9-ml1: Guest Additions Version: 5.1.6
    ml9-ml1: VirtualBox Version: 4.3
```

Usually as long as the Guest Additions version is higher than that of your VirtualBox, you should be good. If it is behind just a little, like GA version 5.1.6 versus VBox Version 5.1.8, you are probably good too. We noticed issues though with older baseboxes that have GA version 5.0.2 in combination with VBox version 5.1.x. You can use the vagrant-vbguest plugin to install the correct Guest Additions if necessary. You can find documentation for its command-line usage here:

https://github.com/dotless-de/vagrant-vbguest#running-as-a-command

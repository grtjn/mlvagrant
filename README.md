# mlvagrant

Scripts for bootstrapping a local MarkLogic cluster for development purposes using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

By default these scripts create 3 'chef/centos-6.5' Vagrant VMs, running in VirtualBox. The names and ips will be recorded in /etc/hosts of host and VMs with use of vagrant-hostmanager. MarkLogic (including dependencies) will be installed on all three vms, and bootstrapped to form a cluster. The OS will be fully updated initially, and "Development Tools" installed as well. Zip/Unzip, Java, MLCP, Nodejs, Bower, Gulp, Forever, Ruby, Git, and Tomcat will be installed, and configured. A bare git repository will be prepared in /space/projects. All automatically with just a few commands.

Each VM takes roughly 2.5Gb. The VM template, together with 3 VMs will take about 10Gb of disk space. In addition, each VM that is launched will claim 2Gb of RAM, and 2 CPU cores. Make sure you have sufficient resources!

Special credits to [@peetkes](https://github.com/peetkes) and [@miguelrgonzalez](https://github.com/miguelrgonzalez) for giving me a head start with this. Thanks to anyone else that has provided help or feedback!

## Getting started

You first need to download and install prerequisites and mlvagrant itself:

- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
- Create /space/software (`sudo mkdir -p /space/software`)
  - **For Windows**: (`c:\space\software`)
- Make sure Vagrant has write access to that folder (`sudo chmod 775 /space/software`)
- Download [MarkLogic 8.0-3 for CentOS](http://developer.marklogic.com/products) (login required)
- Download [MLCP 1.3-3 binaries](http://developer.marklogic.com/download/binaries/mlcp/mlcp-1.3-3-bin.zip)
- Move MarkLogic rpm, and MLCP zip to /space/software (no need to unzip MLCP!)
- Download mlvagrant (`git clone https://github.com/grtjn/mlvagrant.git` or pull down one of its release zips)
- Create /opt/vagrant (`sudo mkdir -p /opt/vagrant`)
  - **For Windows**: (`c:\opt\vagrant`)
- Make sure Vagrant has write access (`sudo chmod 775 /opt/vagrant`)
- Copy mlvagrant/opt/vagrant to /opt/vagrant

Above steps need to taken only once. For every project you wish to create VMs, you simply take these steps:

- Create a new project folder anywhere you like, but with a short name without spaces ('vgtest' for instance)
- Copy mlvagrant/project/Vagrantfile to that folder
- Copy mlvagrant/project/project.properties to that folder
- Open a Terminal or command-line in that folder
- Run:
  - `vagrant plugin install vagrant-hostmanager`
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

## Pushing project code with git

A local git repository with a post-receive hook is initialized for you, together with a user-account for it. All you need to do to push any git repository onto the server is (assuming project name 'vgtest'):

- `git remote add vm vgtest@vgtest-ml1:/space/projects/vgtest.git`
- `git push vm`

The name of the user is derived from the folder name. The password is initialized to equal the user name, but can be changed if desired through:

- `vagrant ssh vgtest-ml1`
- `sudo passwd vgtest`

## Customizing bootstrap

The `project.properties` file contains various settings, amongst others:

- `nr_hosts`, defaults to 3
- `ml_version`, defaults to '8'

The minimum number of hosts is 1, the maximum is limited mostly by the local resources you have available. Each vm will take 2.5Gb of disk space, and by default (also in the Vagrantfile) takes 2Gb of ram, and 2 CPU cores.

Note: although you can technically create a cluster of just 2 nodes, 3 nodes is required for proper fail-over. The cluster needs a quorum to vote if a host should be excluded.

The ml_version is used in the `install-ml-CentOs.sh` script to select the appropriate installer. Code is in place to install versions 5, 6, 7, and 8. The install-ml script refers to rpm by exact name, which includes subversion number, and patch level. Feel free to change it locally to match the exact version you prefer to install.

For other settings see below..

### project_name
Project name - defaults to current directory name

### vm_name
VM naming pattern - defaults to {project_name}-ml{i}, also allowed: {ml_version}

### vm_version
chef/centos base VM version - defaults to 6.5, allowed: 6.5/6.6/7.0/7.1

### ml_version
Major MarkLogic release to install - defaults to 8, allowed: 5,6,7,8 (installers need to be present)

### nr_hosts
Number of hosts in the cluster - defaults to 3, minimum for failover support

### master_memory
Memory assigned to master node in cluster (first vm) - defaults to 2048

### master_cpus
Number of cpus assigned to master node in cluster (first vm) - defaults to 2

### slave_memory
Memory assigned to each slave node in cluster - defaults to same as master_memory

### slave_cpus
Number of cpus assigned to each slave node in cluster - defaults to same as master_cpus

### priv_net_ip
Assign dedicated private IP to master node - slaves get same ip + i

### shared_folder_host/shared_folder_guest
Mount an extra folder from host on vm - project dir is automatically shared as /vagrant

### ml_installer
Override hard-coded MarkLogic installers (file is searched in /space/software, or c:\space\software\ on Windows)

### mlcp_installer
Override hard-coded MLCP installers (file is searched in /space/software, or c:\space\software\ on Windows)

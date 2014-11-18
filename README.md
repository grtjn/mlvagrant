# mlvagrant

Scripts for bootstrapping a local MarkLogic cluster for development purposes using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

By default these scripts create 3 'chef/centos-6.5' Vagrant vms, running in VirtualBox. The names and ips will be recorded in /etc/hosts of host and vms. MarkLogic 7.0-4 (including dependencies) will be installed on all three vms, and bootstrapped to form a cluster. MLCP, Zip/Unzip, Nodejs, Gulp, Forever, and Git will be installed, and configured. A bare git repository will be prepared in /space/projects. All automatically with just a few commands.

Each VM takes roughly 2.5Gb. The template, together with 3 VMs will take about 10Gb of disk space.

Credits to [@peetkes](https://github.com/peetkes) and [@miguelrgonzalez](https://github.com/miguelrgonzalez) for giving me a head start with this.

## Getting started

You first need to download and install prerequisites and mlvagrant itself:

- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Download and install [Vagrant](https://www.vagrantup.com/downloads.html)
- Create /space/software (`sudo mkdir -p /space/software`)
- Download [MarkLogic 7.0-4 for CentOS](http://developer.marklogic.com/download/binaries/7.0/MarkLogic-7.0-4.x86_64.rpm) (go to http://developer.marklogic.com first, login, then open the download url)
- Download [MLCP 1.2.1 binaries](http://developer.marklogic.com/download/binaries/mlcp/mlcp-Hadoop1-1.2-1-bin.zip)
- Move MarkLogic rpm, and MLCP zip to /space/software (no need to unzip MLCP!)
- Download mlvagrant (`git clone https://github.com/grtjn/mlvagrant.git`)
- Create /opt/vagrant (`sudo mkdir -p /opt/vagrant`)
- Copy mlvagrant/opt/vagrant to /opt/vagrant

Above steps need to taken only ones. For every project you wish to create VMs, you simply take these steps:

- Create a new project folder with a short name without spaces ('vgtest' for instance)
- Copy mlvagrant/project/Vagrantfile to that folder
- Open a Terminal or command-line in that folder
- Run:
  - `vagrant plugin install vagrant-hostmanager`
  - `vagrant up --no-provision` (may take a while depending on bandwidth, particularly first time)
  - `vagrant provision` (may take a while, enter sudo password when asked, to allow changing /etc/hosts)

That is all that is necessary to create a fully-prepared 3-node MarkLogic cluster running on CentOS 6.5 VMs. It takes the name of the project folder as prefix for the host names, to make running projects in parallel easier. If you ran the above in a folder called 'vgtest', it will have created three nodes with the names:

- vgtest-v7-ml1 (cluster master)
- vgtest-v7-ml2
- vgtest-v7-ml3

To gain ssh access to the first, you do:

- `vagrant ssh vgtest-v7-ml1`

To take one host down you do:

- `vagrant halt vgtest-v7-ml2`

To take down all you do:

- `vagrant halt`

To destroy all VMs (maybe to recreate them from scratch):

- `vagrant destroy`


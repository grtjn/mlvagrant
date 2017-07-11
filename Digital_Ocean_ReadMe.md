# Vagrant Digital Ocean ReadMe

In addition to the regular setup you will need to run the following command
```sh
$ vagrant plugin install vagrant-digitalocean
```
Once this is done you will need to put in the necessary info into the project.properties file, including your api token and the location of your ssh keys

If you do not have a ssh key to use then you can create one with the following command

```sh
$ ssh-keygen -t rsa
```
Complete the rest of the set up as prompted and save the keys to the folder you specify in project.properties, the default location is the same folder as the vagrantfile and project.properties file

To start an instance type in the following command
```sh
$ vagrant up --provider=digital_ocean --no-provision
```

Once it's finished (it'll take a while!) complete the setup with:

```sh
$ vagrant provision
```
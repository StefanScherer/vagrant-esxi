# Vagrant ESXi Provider

This is a Vagrant plugin for VMware ESXi.

**NOTE:** This is a work in progress, it's based on [vagrant-vsphere](https://github.com/nsidc/vagrant-vsphere) and [vagrant-aws](https://github.com/mitchellh/vagrant-aws), the documentation below is supplementary.

## Usage

    git clone https://github.com/frankus0512/vagrant-esxi
    gem build vagrant-esxi.gemspec
    vagrant plugin install ./vagrant-esxi-*.gem

## ESXi Host Setup

1. enable SSH
2. enable public key authentication, e.g. `cat ~/.ssh/id_rsa.pub | ssh root@host 'cat >> /etc/ssh/keys-root/authorized_keys'`
3. set the license key (if you haven't done so already), e.g. `ssh root@host vim-cmd vimsvc/license --set 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'`

## Example Vagrantfile

    config.vm.box = "precise64_vmware"          // Template (source) VM's name already created on the ESXi
    config.vm.provider :esxi do |esxi|
      esxi.name = "newname"                     // New name you would like to call the (target) VM
      esxi.host = "host"                        // ESXi hostname or IP address
      esxi.srcds = "datastore1"                 // Source datastore name where the source VM is on
      esxi.dstds = "datastore2"                 // Destination datastore name where the target VM will be cloned to
      esxi.user = "root"                        // ESXi username with idrsa.pub key installed
    end

## Issues

https://github.com/frankus0512/vagrant-esxi/issues

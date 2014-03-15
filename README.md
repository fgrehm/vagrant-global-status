# vagrant-global-status

A proof of concept [Vagrant](http://www.vagrantup.com/) plugin that keeps
track of vagrant machines and provides a command for listing the status of all
known machines.

**NOTICE: This plugin is no longer being maintained as its functionality [has been implemented on Vagrant corehttps://github.com/mitchellh/vagrant/pull/3225) and will be available with Vagrant 1.6+.**

## Installation

Make sure you have Vagrant 1.1+ and run:

```
vagrant plugin install vagrant-global-status
```

## Usage

```
vagrant global-status [--all]

    -a, --all       Displays information about all machines (instead of just the active ones)
    -h, --help      Print this help
```

## How does it work?

Whenever you `vagrant up` a VM, the plugin will register the machine name and
path to its `Vagrantfile` on a global state file under `~/.vagrant.d`. That
is enough information for the `global-status` command to do its job and parse
machine's statuses.

After a `vagrant destroy`, the VM will get removed from the global state file
and will no longer show up by default on `vagrant global-status` unless you pass
in `-a` to it.

Besides that, the plugin is smart enough to detect [multiple combinations](lib/vagrant-global-status/global_environment.rb)
of Vagrant environments and is able to get the status for a machine that is
used for development of a Vagrant plugin using Bundler.

## Current limitations / ideas for contributions

* Keeps track of active vagrant-lxc and VirtualBox VMs only
* Detect orphaned machines

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

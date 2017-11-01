# Vagrant

Here you have a few different options for bringing up "px-ready" nodes with `vagrant`

What's nice about these files is that ssh-keys are installed for `root` as part of the provisioning.
So you don't have to set `authorized_keys`.

These are intended for the `ansible` deployments, which have standardized around `systemd`.
Since `ubuntu14` does not support `systemd`, it's not included here.

## Chickens and Eggs

Extracting the appropriate IP addrs, and getting things ready for and `ansible` provision
is a bit of a pain.

Best for now is to run :  `vagrant ssh test1 -- /sbin/ip a show` to see which interfaces are available,
and then run : `./showip <interface>` to populate the ansible inventory and `/etc/hosts` files.



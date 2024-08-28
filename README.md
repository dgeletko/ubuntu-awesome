# ubuntu-awesome

Ansible provisioning scripts to transform a minimal Ubuntu server installation into a lightweight Ubuntu desktop
with the [awesome window manager](https://awesomewm.org) and basic applications for my personal laptop. The goal
is to try to eliminate the _bloat_ of a typical Ubuntu install (including the minimal install). Ubuntu packages
in general pull in a lot of unnecessary dependencies and care must be taken as a simple package install can easily
pull in the entire Gnome desktop, etc. For example, simply installing `libnotify-bin` requires a `notification-daemon`,
so if one is not already installed it defaults to installing the `gnome-shell` package.

The initial goal was a simple lightweight desktop and minimal packages were installed. This goal has somewhat
evolved to simply include all packages from the `ubuntu-desktop-minimal` meta package except those related to the
actual desktop environment to provide users with a more familiar experience. The _depends_ and _recommends_ lists
can be used as a reference on <https://packages.ubuntu.com>.

> **NOTE:** The [qtile](https://qtile.org) window manager is also installed by default now for Wayland support

## Prerequisites

These scripts were written primarily for Ubuntu LTS Linux distributions. The goal is to support the 2 latest LTS
releases.

In order to run the provisioning scripts, Ansible must be installed as a prerequisite. Ansible can be installed
via the Python pip package manager or the standard Ubuntu repositories (`ansible` package). This guide assumes
the scripts will be run locally. Consult the Ansible documentation for remote deployments and more sophisticated
setups.

## Provisioning

This repository contains a single playbook with multiple roles. Hosts can be provisioned using either the
`ansible-playbook` command if this repo is already provisioned locally or via the `ansible-pull` command
which will automatically clone the repo.

- **OPTION 1:** Running directly from local cloned git repo:

  ```bash
  $ ansible-playbook -i hosts --ask-become-pass ubuntu.yml
  ```

- **OPTION 2:** Pulling and running from remote git repo url:

  ```bash
  $ ansible-pull --url https://github.com/dgeletko/ubuntu-awesome -i hosts --ask-become-pass ubuntu.yml
  ```

## Testing

The repo includes [Vagrant](https://www.vagrantup.com) support for testing in a
[VirtualBox](https://www.virtualbox.org) virtual machine using [Bento](https://app.vagrantup.com/bento) project
base boxes. To provision a VM, simply run the following from the repo root:

  ```bash
  $ vagrant up
  ```

> **NOTE:** There will be some package differences due to how the base boxes strip some of the server packages.


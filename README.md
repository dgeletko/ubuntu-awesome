# ubuntu-awesome

[Ansible](https://www.ansible.com) provisioning scripts to transform a minimal Ubuntu server installation into a
lightweight Ubuntu desktop with the [awesome window manager](https://awesomewm.org) and basic applications for my
personal laptop. The goal is to try to eliminate the _bloat_ of a typical Ubuntu install (including the minimal
install). Ubuntu packages in general pull in a lot of unnecessary dependencies and care must be taken as a simple
package install can easily pull in the entire Gnome desktop, etc. For example, simply installing `libnotify-bin`
requires a `notification-daemon`, so if one is not already installed it defaults to installing the `gnome-shell`
package.

The initial goal was a simple lightweight desktop and minimal packages were installed. This goal has somewhat
evolved to simply include all packages from the `ubuntu-desktop-minimal` meta package except those related to the
actual desktop environment to provide users with a more familiar experience. The _depends_ and _recommends_ lists
can be used as a reference on <https://packages.ubuntu.com>.

> **NOTE:** The [qtile](https://qtile.org) window manager is also installed by default now for Wayland support

## Prerequisites

These scripts were written primarily for Ubuntu LTS Linux distributions. The goal is to support the 2 latest LTS
releases. The following Ubuntu releases are supported:

* 22.04 (Jammy Jellyfish)
* 24.04 (Noble Numbat)

In order to run the provisioning scripts, Ansible must be installed as a prerequisite. Ansible can be installed
via the Python pip package manager (`pip install ansible`) or from the standard Ubuntu repositories
(`apt install ansible`). This guide assumes the user is familiar with Ansible, or why else are you here? See project
documentation for details.

## Provisioning

This repository contains a single `standard.yml` playbook that includes multiple roles. Hosts can be provisioned
either locally or from a remote control host. The following table describes the roles:

| Role  | Description                                                         |
| ----- | ------------------------------------------------------------------- |
| core  | Core minimal Ubuntu environment (non-server)                        |
| base  | Base system w/ standard Ubuntu desktop packages and window managers |
| user  | Custom user Ubuntu system                                           |
| vbox  | Specialized for running in Virtualbox or using the Vagrant test VM  |

### Local

This repository contains a single playbook with multiple roles. Hosts can be provisioned using either the
`ansible-playbook` command if this repo is already provisioned locally or via the `ansible-pull` command
which will automatically clone the repo.

- **OPTION 1:** Running directly from local cloned git repo:

  ```bash
  $ git clone https://github.com/dgeletko/ubuntu-awesome.git
  $ cd ubuntu-awesome
  $ ansible-playbook -i hosts -K standard.yml
  ```

- **OPTION 2:** Pulling and running from remote git repo url:

  ```bash
  $ ansible-pull --url https://github.com/dgeletko/ubuntu-awesome -i hosts -K standard.yml
  ```

### Remote

If provisioning from a remote control host, it is assumed that SSH is properly configured for key login.

```bash
$ ansible-playbook -i <host>, -K standard.yml
```

> **NOTE:** The comma is required after the host/IP

## Testing

The repo includes [Vagrant](https://www.vagrantup.com) support for testing in a
[VirtualBox](https://www.virtualbox.org) virtual machine using [Bento](https://app.vagrantup.com/bento) project
base boxes. To provision a VM, simply run the following from the repo root:

  ```bash
  $ vagrant up
  ```


guacamolerdp-ansible
=========

This role prepares a fresh Ubuntu 18.04 instance to be a fully fledged working environment via Xfce4 and XRDP.
XRDP gets bundled with guacamole, a clientless remote desktop web gateway.

Aim of this is, that we can "reverse proxy" a remote desktop session to a privileged user with a remoteproxy webserver
provisioned with [de.NBI FORC](https://github.com/deNBI/simpleVMWebGateway).

**For security reasons, you should execute this role on a VM, which is not publicly reachable via internet. Protect the VM with authentication via ReverseProxy, firewall etc.**

Also an important security notification:

Guacamole needs a valid unix user and password to automatically create and connect to a valid rdp session.
This role creates a default user with a default password described in `vars/main.yml`. You have been warned.
For more see the `Role Variables` section.

Requirements
------------

* Ubuntu 18.04
* Internet connection on the target
* Guacamole runs on port `8080`, make sure its not in use already.

Role Variables
--------------

**Again: If the targeted machine is not externaly protected or not used in a FORC environment with appropriate firewall rules, change these values!!!**

**vars/main.yml**

| Variable                  | Description           | Default        | Mandatory |
| -------------             |-------------          |----------------|     ---   |
| default_user           | Default unix user on which guacamole connects to | ubuntu         | Yes       |
| default_password              | Default password of the unix user. Change it when target is not externally protected via ReverseProxy or other.                                  | denbi          | Yes       |
| default_password_hashed         | Hashed password of default_password      | $6$iRrIJogr... |   Yes     |
| guac_user        | Default guacamole user                 | denbi          | Yes       |
| guac_password         | Default guacamole password                        | denbi          | Yes       |


Dependencies
------------

* No dependencies.

Example Playbook
----------------

Make sure to include `become: true`. Using this role in a playbook is straight forward:

    - hosts: servers
      become: true
      roles:
         - guacamolerdp-ansible

License
-------

Apache 2.0

Author Information
------------------

Alex Walender

de.NBI Cloud Bielefeld

# resenvs
This repository is used to create ready-to-launch images installed with a research environment of choice.

Currently available research environments: CWLab, Guacamole, RStudio, TheiaIDE

## Development workflow
```mermaid
graph TD
    B[Openstack Cloud<br> Bielefeld] --> |1. provides latest<br> images| S3[(S-3 Storage <br> Openstack Bielefeld)]
    S3 --> |2. uploads latest<br> base images| B
    S3 --> |2. uploads latest<br> base images| G[Openstack Cloud <br> Giessen]
```
Openstack Cloud Bielefeld regularly updates images of different Linux distributions (e.g. Ubuntu). These images will be configured as base images for SimpleVM and uploaded to both Openstack Cloud locations.
1. Newest base images on Openstack Cloud Bielefeld are uploaded to S3 Object storage
2. The images in S3 storage are regularly checked. When there are newer version of a base image which is not present on Openstack Giessen, it will be downloaded via a S3 tool and uploaded to Openstack Bielefeld and Openstack Giessen

[Packer](packer.io) is used to create pre-built resenv images. The procedure is as follows:

```mermaid
graph TD
    P[Packer] -- 1. connects to<br> cloud --> OS[Openstack Cloud]
    OS -->|2. creates with<br> Packer-generated<br> keypair| I[Base image<br> instance]
    P -- 3. installs<br> resenv script<br> remotely --> I
    I -- 4. creates<br> snapshot --> OS
```

1. Packer connects to Openstack Cloud and launches an instance from a base image
2. An installing script is executed remotely to equip the created instance with necessary dependencies
3. A snapshot of the prepared instance is created
4. The created snapshot with research environment installed is stored as a new image

## Configuration of GitHub Runners
In order to run the workflows with internal GitHub runners, they should have the following dependencies installed:
- [Packer](https://www.packer.io/downloads) (v. 1.6 or higher)
- [Minio CLI](https://min.io/download#/linux)  
Also setup valid credentials for Minio client with `./mc alias set osbielefeld https://openstack.cebitec.uni-bielefeld.de:8080 ACCESS_KEY SECRET_KEY`. You can create a keypair with `openstack credential create`
- openstacksdk `pip install openstacksdk`
- OpenStack RC Files for both Bielefeld and Giessen under home directory, named after `packer-rc-{location}.sh` respectively

# resenvs
This repository is used to create ready-to-launch images installed with a research environment of choice.

Currently available research environments: CWLab, Guacamole, RStudio, TheiaIDE

## Development workflow
The image creation is realised with [Packer](packer.io). The procedure is as follows:

![Packer workflow](https://github.com/qqmok/documents/blob/main/resenvs.drawio.svg)

1. Packer connects to Openstack Cloud and launches an instance from a base image
2. An installing script is executed remotely to equip the created instance with necessary dependencies
3. A snapshot of the prepared instance is created
4. The created snapshot with research environment installed is stored as a new image

Additionally, updates of base images on Openstack Giessen is also managed through GitHub Actions:

5. Newest base images on Openstack Bielefeld are uploaded to S3 Object storage
6. The images in S3 storage are regularly checked. When there are newer version of a base image which is not present on Openstack Giessen, it will be downloaded via a S3 tool and uploaded to Openstack Giessen

## Configuration of GitHub Runners
In order to run the workflows with internal GitHub runners, they should have the following dependencies installed:
- [Packer](https://www.packer.io/downloads) (v. 1.6 or higher)
- [Minio CLI](https://min.io/download#/linux)  
Also setup valid credentials for Minio client with `./mc alias set osbielefeld https://openstack.cebitec.uni-bielefeld.de:8080 ACCESS_KEY SECRET_KEY`. You can create a keypair with `openstack credential create`
- openstacksdk `pip install openstacksdk`
- OpenStack RC Files for both Bielefeld and Giessen under home directory, named after `packer-rc-{location}.sh` respectively

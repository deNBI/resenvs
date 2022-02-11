# resenvs
This repository is used to create ready-to-launch images installed with a research environment of choice.

Currently availabel research environments: CWLab, Guacamole, RStudio, TheiaIDE

## Development workflow
The image creation is realised with [Packer](packer.io). The procedure is as follows:

![Packer workflow](https://github.com/qqmok/documents/blob/main/resenvs.drawio.svg)

1. Packer connects to Openstack Cloud and launch an instance from a base image
2. An installing script is executed remotely to equip the created instance with necessary dependencies
3. A snapshot of the prepared instance is created
4. The created snapshot with research environment installed is stored as a new image

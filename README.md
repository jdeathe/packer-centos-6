# CentOS-6 Base Box

This provides the configuration to build a [Vagrant](https://www.vagrantup.com) base box using [Packer](https://www.packer.io)

## WIP

This is currently work-in progress. Do not use for anything other than experimental works.

## Usage Instructions

### Prerequisites

To build the box file you will need the following installed:

- [VirtualBox](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)
- [Packer](https://www.packer.io)

### Download Source ISO

To build the base box first download the ISO image [CentOS-6.8-x86_64-minimal.iso](http://mirrors.kernel.org/centos/6.8/isos/x86_64/CentOS-6.8-x86_64-minimal.iso) to the directory `isos/x86_64` - This step shouldn't be necessary but Packer failed to download the file in my case.

```
$ curl -o \
  isos/x86_64/CentOS-6.8-x86_64-minimal.iso \
  http://mirrors.kernel.org/centos/6.8/isos/x86_64/CentOS-6.8-x86_64-minimal.iso
```

### Build

To build the base box run the following Packer command

```
$ packer build centos-6.json
```
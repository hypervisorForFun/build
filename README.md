   # hypervisorForFun build.git

## Contents
1. [Introduction](#1-introduction)
2. [Why repo?](#2-why-repo)
3. [Get and build the solution](#3-get-and-build-the-solution)


# 1. Introduction
Why this particular git? Well, as it turns out it's totally possible to put
together everything on your own. You can build all the individual components,
os, client, xtest, Linux kernel, ARM-TF, TianoCore, QEMU, BusyBox etc and put
all the binaries at correct locations and write your own command lines,
Makefiles, shell-scripts etc that will work nicely on the devices you are
interested in. If you know how to do that, fine, please go a head. But for
newcomers it's way to much behind the scenes to be able to setup a working
environment. Also, if you for some reason want to run something in an automated
way, then you need something else wrapping it up for you.

With this particular git **built.git** our goal is to:<br>
**Make it easy for newcomers to get started with hypervisorForFun using qemu.**

# 2. Why repo?
We discussed alternatives, initially we started out with having a simple
shell-script, that worked to start with, but after getting more gits in use and
support for more devices it started to be difficult to maintain. In the end we
ended up choosing between [repo] from the Google AOSP project and [git
submodules]. No matter which you choose, there will always be some person
arguing that one is better than the other. For us we decided to use repo. Not
directly for the features itself from repo, but for the ability to simply work
with different manifests containing both stable and non-stable release. Using
some tips and tricks you can also speed up setup time significantly. For day to
day work with commits, branches etc we tend to use git commands directly.


# 3. Get and build the solution
Below we will describe the general way of getting the source, building the
solution and how to run xtest on the device. For device specific instructions,
see the respective `device.md` file in the [docs] folder.

## 3.1 Prerequisites
We believe that you can use any Linux distribution to build qemu, xen, but as
maintainers of hypervisorForFun we are mainly using Ubuntu-based distributions and to be
able to build and run hypervisor there are a few packages that needs to be installed
to start with. Therefore install the following packages regardless of what
target you will use in the end.

```bash
$ sudo apt-get install android-tools-adb android-tools-fastboot autoconf \
	automake bc bison build-essential cscope curl device-tree-compiler \
	expect flex ftp-upload gdisk iasl libattr1-dev libc6:i386 libcap-dev \
	libfdt-dev libftdi-dev libglib2.0-dev libhidapi-dev libncurses5-dev \
	libpixman-1-dev libssl-dev libstdc++6:i386 libtool libz1:i386 make \
	mtools netcat python-crypto python-serial python-wand unzip uuid-dev \
	xdg-utils xterm xz-utils zlib1g-dev
```


## 3.2 Get the source code
You can use below command to get all source code of this project

```bash
$ mkdir -p $HOME/devel/hypervisorForFun
$ cd $HOME/devel/hypervisorForFun
$ repo init -u https://github.com/hypervisorForFun/manifest.git -m default.xml --repo-url=git://codeaurora.org/tools/repo.git
$ repo sync -j8
```
## 3.4 Get the toolchains
In hypervisorForFun we're using different toolchains for different targets (depends on
ARMv7-A ARMv8-A 64/32bit solutions). In any case start by downloading the
toolchains by:
```bash
$ cd build
$ make -f toolchains.mk toolchains
```

## 3.5 sync sub-git of edk2
In hypervisorForFun, there are a default UEFI image whcih can be used to load xen, But
if you want to rebuild it, you needd to syn code of openssl in path of edk2.  you can 
use below command to do this:
```bash
$ cd edk2
$ git submodule update --init --recursive
```
In default condition, build system will not rebuild uefi image, but you can rebuild
uefi image by changing variable of "CFG_REBUILD_UEFI" to "y"

## 3.6 Build the solution
We've configured our repo manifests, so that repo will always automatically
symlink the `Makefile` to the correct device specific makefile, that means that
you simply start the build by running:

```bash
$ make
$ make -f qemu_v8.mk all -j8
```
This step will also take some time, but you can speed up subsequent builds by
enabling [ccache] (again see Tips and Tricks).



#
# Common definition to all platforms
#

SHELL := bash
BASH ?= bash
ROOT ?= $(shell pwd)/..
BUILD_PATH			?= $(ROOT)/build
LINUX_PATH			?= $(ROOT)/linux
EDK2_PATH			?= $(ROOT)/edk2
XEN_PATH			?= $(ROOT)/xen
OUT_PATH			?= $(ROOT)/out/
GEN_ROOTFS_PATH		?= $(ROOT)/gen_rootfs
GEN_ROOTFS_FILELIST ?= $(GEN_ROOTFS_PATH)/filelist-tee.txt 

LINUX_OUTPUT_IMAGE ?= $(LINUX_PATH)/arch/arm64/boot/Image.gz



QEMU_CONFIGURE_PARAMS_COMMON = --cc="gcc" --extra-cflags="-Wno-error -g3" \
			       --disable-strip --extra-ldflags="-g3" \
			       --enable-debug --disable-pie
fl:=$(GEN_ROOTFS_FILELIST)



################################################################################
# Linux
################################################################################
LINUX_COMMON_FLAGS ?= CROSS_COMPILE=$(AARCH64_CROSS_COMPILE)

.PHONY: linux-common
linux-common: linux-defconfig
	$(MAKE) -C $(LINUX_PATH) $(LINUX_COMMON_FLAGS)
	$(shell cp $(LINUX_OUTPUT_IMAGE) $(OUT_PATH))


$(LINUX_PATH)/.config: $(LINUX_DEFCONFIG_COMMON_FILES)
	cd $(LINUX_PATH) && \
		ARCH=$(LINUX_DEFCONFIG_COMMON_ARCH) \
		scripts/kconfig/merge_config.sh $(LINUX_DEFCONFIG_COMMON_FILES) \
			$(LINUX_DEFCONFIG_BENCH)

.PHONY: linux-defconfig-clean-common
linux-defconfig-clean-common:
	rm -f $(LINUX_PATH)/.config

# LINUX_CLEAN_COMMON_FLAGS should be defined in specific makefiles (hikey.mk,...)
.PHONY: linux-clean-common
linux-clean-common: linux-defconfig-clean
	$(MAKE) -j4 -C $(LINUX_PATH) $(LINUX_CLEAN_COMMON_FLAGS) clean

# LINUX_CLEANER_COMMON_FLAGS should be defined in specific makefiles (hikey.mk,...)
.PHONY: linux-cleaner-common
linux-cleaner-common: linux-defconfig-clean
	$(MAKE) -C $(LINUX_PATH) $(LINUX_CLEANER_COMMON_FLAGS) distclean
	
	
	




################################################################################
# xen
################################################################################
XEN_COMMON_FLAGS ?= CROSS_COMPILE=$(AARCH64_CROSS_COMPILE)
XEN_COMMON_FLAGS += XEN_TARGET_ARCH=arm64
XEN_COMMON_TARGET := dist-xen
.PHONY: xen-common
xen-common:
	cd $(XEN_PATH) && \
	$(MAKE) $(XEN_COMMON_FLAGS) dist-xen


################################################################################
# edk2-common
################################################################################
.PHONY: edk2-common
edk2-common:
	cd $(EDK2_PATH) && \
	$(MAKE) -C BaseTools && \
	source edksetup.sh && \
	build -a AARCH64 -t GCC49 -p ArmVirtPkg/ArmVirtQemu.dsc && \
	cp Build/ArmVirtQemu-AARCH64/DEBUG_GCC49/FV/QEMU_EFI.fd $(UEFI_PATH)/
	
	




################################################################################
# rootfs
################################################################################
.PHONY: update_rootfs-common
update_rootfs-common: busybox filelist-tee
	cat $(GEN_ROOTFS_PATH)/filelist-final.txt > $(GEN_ROOTFS_PATH)/filelist.tmp
	cat $(GEN_ROOTFS_FILELIST) >> $(GEN_ROOTFS_PATH)/filelist.tmp
	cd $(GEN_ROOTFS_PATH) && \
	        $(LINUX_PATH)/usr/gen_init_cpio $(GEN_ROOTFS_PATH)/filelist.tmp | \
			gzip > $(GEN_ROOTFS_PATH)/filesystem.cpio.gz

.PHONY: update_rootfs-clean-common
update_rootfs-clean-common:
	rm -f $(GEN_ROOTFS_PATH)/filesystem.cpio.gz
	rm -f $(GEN_ROOTFS_PATH)/filelist-all.txt
	rm -f $(GEN_ROOTFS_PATH)/filelist-tmp.txt
	rm -f $(GEN_ROOTFS_FILELIST)

.PHONY: filelist-tee-common
filelist-tee-common:
	@echo "# filelist-tee-common /start" 				> $(fl)
	@echo "# filelist-tee-common /end"				>> $(fl)
	
	
	
	
################################################################################
# Busybox
################################################################################
.PHONY: busybox-common
busybox-common: linux
	cd $(GEN_ROOTFS_PATH) &&  \
		CROSS_COMPILE=$(AARCH64_CROSS_COMPILE) \
		PATH=${PATH}:$(LINUX_PATH)/usr \
		$(GEN_ROOTFS_PATH)/generate-cpio-rootfs.sh \
			$(BUSYBOX_COMMON_TARGET)

.PHONY: busybox-clean-common
busybox-clean-common:
	cd $(GEN_ROOTFS_PATH) && \
	$(GEN_ROOTFS_PATH)/generate-cpio-rootfs.sh  \
		$(BUSYBOX_CLEAN_COMMON_TARGET)

.PHONY: busybox-cleaner-common
busybox-cleaner-common:
	rm -rf $(GEN_ROOTFS_PATH)/build
	rm -rf $(GEN_ROOTFS_PATH)/filelist-final.txt

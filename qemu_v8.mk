
-include common.mk
-include toolchain.mk



### Below are all variables which will be used during building period ##########
QEMU_PATH		?= $(ROOT)/qemu
SOC_TERM_PATH		?= $(ROOT)/soc_term
UEFI_PATH	?= $(ROOT)/uefi_image

FILESYSTEM_L1_PATH ?= $(ROOT)/filesystem_L1
SRC_FILESYSTEM_L1 ?= https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img 
FILESYSTEM_L1_NAME ?= $(FILESYSTEM_L1_PATH)/ubuntu.qcow2
GEN_ROOT_PATH ?= $(ROOT)/gen_rootfs

CFG_REBUILD_UEFI  ?= n

################## Below are all modules' define ###############################

################################################################################
# all 
################################################################################
all: out qemu soc-term linux update_rootfs xen filesystem edk2
clean: busybox-clean edk2-clean linux-clean qemu-clean \



################################################################################
# output
################################################################################
define create_output                                                                                                                                                             
	@if [ ! -f "$(OUT_PATH)" ]; then \
		mkdir -p $(OUT_PATH); \
	fi
endef
out:
	$(call create_output)
   


################################################################################
# Soc-term
################################################################################
soc-term:out
	$(MAKE) -C $(SOC_TERM_PATH)
	$(shell cp $(SOC_TERM_PATH)/soc_term $(OUT_PATH))

soc-term-clean:
	$(MAKE) -C $(SOC_TERM_PATH) clean

################################################################################
# edk2
################################################################################
ifeq ($(CFG_REBUILD_UEFI),y)
edk2: edk2-common out
else
edk2: out
endif
	$(shell cp $(UEFI_PATH)/QEMU_EFI.fd $(OUT_PATH))


################################################################################
# xen
################################################################################
xen: xen-common out
	$(shell cp $(XEN_PATH)/xen/xen.efi $(OUT_PATH))

################################################################################
# filesystem of L1
################################################################################
define dlfs                                                                                                                                                             
	@if [ ! -f "$(FILESYSTEM_L1_NAME)" ]; then \
		mkdir -p $(FILESYSTEM_L1_PATH); \
		echo "Downloading $(FILESYSTEM_L1_NAME) ..."; \
		wget $(SRC_FILESYSTEM_L1) -O $(FILESYSTEM_L1_NAME); \
	fi
endef

filesystem: out
	$(call dlfs)
	$(shell cp $(FILESYSTEM_L1_NAME) $(OUT_PATH))


################################################################################
# Linux kernel
################################################################################
LINUX_DEFCONFIG_COMMON_ARCH := arm64
LINUX_DEFCONFIG_COMMON_FILES := \
		$(LINUX_PATH)/arch/arm64/configs/defconfig \
		$(CURDIR)/kconfigs/qemu.conf

linux-defconfig: $(LINUX_PATH)/.config

LINUX_COMMON_FLAGS += ARCH=arm64

linux: linux-common out

linux-defconfig-clean: linux-defconfig-clean-common

LINUX_CLEAN_COMMON_FLAGS += ARCH=arm64

linux-clean: linux-clean-common

LINUX_CLEANER_COMMON_FLAGS += ARCH=arm64

linux-cleaner: linux-cleaner-common







################################################################################
# QEMU
################################################################################
qemu: out
	cd $(QEMU_PATH); ./configure --target-list=aarch64-softmmu\
			$(QEMU_CONFIGURE_PARAMS_COMMON)
	$(MAKE) -C $(QEMU_PATH)

qemu-clean:
	$(MAKE) -C $(QEMU_PATH) distclean
	
	
	
	
	
	
################################################################################
# Root FS
################################################################################
filelist-tee: filelist-tee-common
update_rootfs: update_rootfs-common
	$(shell cp -rf $(GEN_ROOT_PATH)/filesystem.cpio.gz $(OUT_PATH))





################################################################################
# Busybox
################################################################################
BUSYBOX_COMMON_TARGET = vexpress
BUSYBOX_CLEAN_COMMON_TARGET = vexpress clean
BUSYBOX_COMMON_CCDIR = $(AARCH64_PATH)

busybox: busybox-common out

busybox-clean: busybox-clean-common

busybox-cleaner: busybox-cleaner-common

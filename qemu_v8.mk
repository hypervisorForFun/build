
-include common.mk
-include toolchain.mk



### Below are all variables which will be used during building period ##########

QEMU_PATH		?= $(ROOT)/qemu
SOC_TERM_PATH		?= $(ROOT)/soc_term


################## Below are all modules' define ###############################

################################################################################
# all 
################################################################################
all: qemu soc-term linux update_rootfs xen
clean: busybox-clean edk2-clean linux-clean qemu-clean \



################################################################################
# Soc-term
################################################################################
soc-term:
	$(MAKE) -C $(SOC_TERM_PATH)

soc-term-clean:
	$(MAKE) -C $(SOC_TERM_PATH) clean


################################################################################
# xen
################################################################################
xen: xen-common



################################################################################
# Linux kernel
################################################################################
LINUX_DEFCONFIG_COMMON_ARCH := arm64
LINUX_DEFCONFIG_COMMON_FILES := \
		$(LINUX_PATH)/arch/arm64/configs/defconfig \
		$(CURDIR)/kconfigs/qemu.conf

linux-defconfig: $(LINUX_PATH)/.config

LINUX_COMMON_FLAGS += ARCH=arm64

linux: linux-common

linux-defconfig-clean: linux-defconfig-clean-common

LINUX_CLEAN_COMMON_FLAGS += ARCH=arm64

linux-clean: linux-clean-common

LINUX_CLEANER_COMMON_FLAGS += ARCH=arm64

linux-cleaner: linux-cleaner-common







################################################################################
# QEMU
################################################################################
qemu:
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





################################################################################
# Busybox
################################################################################
BUSYBOX_COMMON_TARGET = vexpress
BUSYBOX_CLEAN_COMMON_TARGET = vexpress clean
BUSYBOX_COMMON_CCDIR = $(AARCH64_PATH)

busybox: busybox-common

busybox-clean: busybox-clean-common

busybox-cleaner: busybox-cleaner-common

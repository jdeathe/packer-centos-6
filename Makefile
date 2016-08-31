export SHELL := /usr/bin/env bash
export PATH := ${PATH}

BOX_NAMESPACE := jdeathe
BOX_PROVIDOR := virtualbox
BOX_ARCH_PATTERN := ^(x86_64|i386)$

BOX_ARCH ?= x86_64
BOX_DEBUG ?= false
BOX_LANG ?= en_US
BOX_MINOR_RELEASE ?= 6.8
BOX_OUTPUT_PATH ?= ./builds
BOX_VERSION ?= 6

# UI constants
COLOUR_NEGATIVE := \033[1;31m
COLOUR_POSITIVE := \033[1;32m
COLOUR_RESET := \033[0m
CHARACTER_STEP := ==>
PREFIX_STEP := $(shell printf -- '%s ' "$(CHARACTER_STEP)")
PREFIX_SUB_STEP := $(shell printf -- ' %s ' "$(CHARACTER_STEP)")
PREFIX_STEP_NEGATIVE := $(shell printf -- '%b%s%b' "$(COLOUR_NEGATIVE)" "$(PREFIX_STEP)" "$(COLOUR_RESET)")
PREFIX_STEP_POSITIVE := $(shell printf -- '%b%s%b' "$(COLOUR_POSITIVE)" "$(PREFIX_STEP)" "$(COLOUR_RESET)")
PREFIX_SUB_STEP_NEGATIVE := $(shell printf -- '%b%s%b' "$(COLOUR_NEGATIVE)" "$(PREFIX_SUB_STEP)" "$(COLOUR_RESET)")
PREFIX_SUB_STEP_POSITIVE := $(shell printf -- '%b%s%b' "$(COLOUR_POSITIVE)" "$(PREFIX_SUB_STEP)" "$(COLOUR_RESET)")

.DEFAULT_GOAL := build

# Get absolute file paths
BOX_OUTPUT_PATH := $(realpath $(BOX_OUTPUT_PATH))

# Package prerequisites
curl := $(shell type -p curl)
gzip := $(shell type -p gzip)
openssl := $(shell type -p openssl)
packer := $(shell type -p packer)
vagrant := $(shell type -p vagrant)
vboxmanage := $(shell type -p vboxmanage)

.PHONY: \
	all \
	build \
	install \
	prerequisites \
	require-supported-architecture

all: prerequisites | build

build: prerequisites require-supported-architecture download-iso
	@ echo "$(PREFIX_STEP)Building CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR)"
	@ if [[ ! -f CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG).json ]]; then \
			echo "$(PREFIX_SUB_STEP_NEGATIVE) Missing var-file: CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG).json"; \
			exit 1; \
		elif [[ ! -f CentOS-6-$(BOX_PROVIDOR).json ]]; then \
			echo "$(PREFIX_SUB_STEP_NEGATIVE) Missing template: CentOS-6-$(BOX_PROVIDOR).json"; \
			exit 1; \
		else \
			if [[ $(BOX_DEBUG) == true ]]; then \
				$(packer) build \
					-debug \
					-force \
					-var-file=CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG).json \
					CentOS-6-$(BOX_PROVIDOR).json; \
			else \
				$(packer) build \
					-force \
					-var-file=CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG).json \
					CentOS-6-$(BOX_PROVIDOR).json; \
			fi; \
			if [[ $${?} -eq 0 ]]; then \
				$(openssl) sha1 \
					$(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box \
					| awk '{ print $$2; }' \
					> $(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box.sha1; \
				echo "$(PREFIX_SUB_STEP_POSITIVE) Build complete"; \
			else \
				rm -f $(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box.sha1 &> /dev/null; \
				echo "$(PREFIX_SUB_STEP_NEGATIVE) Build error"; \
				exit 1; \
			fi; \
		fi

download-iso: prerequisites require-supported-architecture
	@ if [[ ! -f isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso ]]; then \
			if [[ ! -d ./isos/$(BOX_ARCH) ]]; then \
				mkdir -p ./isos/$(BOX_ARCH); \
			fi; \
			echo "$(PREFIX_STEP) Downloading ISO"; \
			$(curl) -LSo ./isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso \
				http://mirrors.kernel.org/centos/$(BOX_MINOR_RELEASE)/isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso; \
			if [[ $${?} -eq 0 ]]; then \
				rm -f ./isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso &> /dev/null; \
				echo "$(PREFIX_STEP) Download failed - trying vault"; \
				$(curl) -LSo ./isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso \
					http://archive.kernel.org/centos-vault/$(BOX_MINOR_RELEASE)/isos/$(BOX_ARCH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal.iso; \
			fi; \
		fi

install: prerequisites require-supported-architecture
	$(eval $@_box_name := $(shell \
		echo "CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)" \
			| awk '{ print tolower($$1); }' \
	))
	$(eval $@_box_checksum := $(shell \
		$(openssl) sha1 \
			$(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box \
			| awk '{ print $$2; }' \
	))
	$(eval $@_box_hash := $(shell \
		echo "$($@_box_checksum)" \
			| cut -c1-8 \
	))
	@ if [[ -f $(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box ]]; then \
			echo "$(PREFIX_STEP)Installing $(BOX_NAMESPACE)/$($@_box_name)/$($@_box_hash)"; \
			$(vagrant) box add --force \
				--name $(BOX_NAMESPACE)/$($@_box_name)/$($@_box_hash) \
				$(BOX_OUTPUT_PATH)/CentOS-$(BOX_MINOR_RELEASE)-$(BOX_ARCH)-minimal-$(BOX_LANG)-$(BOX_PROVIDOR).box; \
			echo "$(PREFIX_STEP)Vagrantfile:"; \
			$(vagrant) init --output - --minimal $(BOX_NAMESPACE)/$($@_box_name)/$($@_box_hash); \
		else \
			echo "$(PREFIX_STEP_NEGATIVE) No box file."; \
			echo "$(PREFIX_SUB_STEP) Try running: make build"; \
		fi

prerequisites:
ifeq ($(vboxmanage),)
	$(error "Please install VirtualBox. (https://www.virtualbox.org/)")
endif

ifeq ($(vagrant),)
	$(error "Please install Vagrant. (https://www.vagrantup.com)")
endif

ifeq ($(packer),)
	$(error "Please install Packer. (https://www.packer.io)")
endif

ifeq ($(curl),)
	$(error "Please install the curl package.")
endif

ifeq ($(gzip),)
	$(error "Please install the gzip package.")
endif

ifeq ($(openssl),)
	$(error "Please install the openssl package.")
endif

require-supported-architecture:
	@ if [[ ! $(BOX_ARCH) =~ $(BOX_ARCH_PATTERN) ]]; then \
			echo "$(PREFIX_STEP_NEGATIVE)Unsupported architecture ($(BOX_ARCH))"; \
			echo "$(PREFIX_SUB_STEP) Supported values: x86_64|i386."; \
			exit 1; \
		fi

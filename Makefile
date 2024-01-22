SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

VAGRANT ?= vagrant
ANSIBLE ?= ansible-playbook
VG_INTERFACE=enp0s8

TARGET_HOSTS ?= all
WIPE ?= false
WIPE_TARGET ?= all
RUN_AS_DOCKER ?= false



ifneq ($(WIPE),true)
	override WIPE=false
endif

ifneq ($(RUN_AS_DOCKER),true)
	override RUN_AS_DOCKER=false
endif

.PHONY: test
test:
	$(ANSIBLE) provision.yaml \
		-i inventory/test/hosts.yaml \
		$(ANSIBLE_FLAGS) \
		-e 'node1_ssh_port=$(shell $(VAGRANT) port --guest 22 node1)' \
		-e 'node2_ssh_port=$(shell $(VAGRANT) port --guest 22 node2)' \
		-e 'bootnode_on_host=node1' \
		-e 'bootnode_ip_addr=$(shell $(VAGRANT) ssh node1 -c "ip address show $(VG_INTERFACE) | grep 'inet ' | sed -e 's/^.*inet //' -e 's/\/.*$$//'")' \
		-e '{"wipe": $(WIPE)}' \
		-e 'wipe_target=$(WIPE_TARGET)' \
		-e '{"run_as_docker": $(RUN_AS_DOCKER)}' \
		-e 'target=$(TARGET_HOSTS)'

.PHONY: start-vagrant
start-vagrant:
ifeq ($(VG_DESTROY),true)
	$(MAKE) destroy-vagrant
endif
	$(VAGRANT) up

.PHONY: destroy-vagrant
destroy-vagrant:
	$(VAGRANT) destroy -f

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

VAGRANT ?= vagrant
ANSIBLE ?= ansible-playbook

TARGET_HOSTS ?= all

.PHONY: test
test:
	$(ANSIBLE) provision.yaml \
		-i inventory/test/hosts.yaml \
		$(ANSIBLE_FLAGS) \
		-e 'node1_ssh_port=$(shell $(VAGRANT) port --guest 22 node1)' \
		-e 'node2_ssh_port=$(shell $(VAGRANT) port --guest 22 node2)' \
		-e 'target=$(TARGET_HOSTS)' \
		-e 'miners=$(MINERS)' \

start-vagrant:
ifeq ($(DESTROY),true)
	$(VAGRANT) destroy -f || true
endif
	$(VAGRANT) up

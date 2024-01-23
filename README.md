# Eth Ansible

Provision Ethereum Proof-of-Authority nodes using Ansible (Experimental). This project is currently designed to match local development, but you can also run it on VMs. Guidelines can be found at the end of this document.

> Currently, this project only supports deploying a Geth node as a Private Network with the Clique consensus algorithm (Proof-of-Authority).

## Prerequisites

This project is experimental, and to run it locally for development or testing, some tools are required.

- **Vagrant**: Used to spawn local VMs. In this project, Vagrant is set up with 2 VMs. You can also tweak it by changing the settings in [Vagrantfile](./Vagrantfile).
- **make**: Used to wrap commands for local environment setup.
- **ansible**: Used to run playbooks to set up `geth` on VMs.
- **OS**: Debian / Ubuntu (22.04)
- **Arch**:
  - `x86_64`
  - `aarch64` (not tested yet)

## Quick Start

### Start Vagrant

This step is only run once.

```console
$ make start-vagrant
```

### Run tests

If you want to win fast, you can run the command below:

```console
$ make ANSIBLE_ARGS='-v' test
```

The command above will deploy 2 Geth nodes with Private Network setup (currently, this only supports the Clique consensus algorithm) and with default values (You can find them here [defaults/main.yaml](./roles/geth/defaults/main.yaml)).

You can test the nodes by running some curl commands:

```console
$ curl -sSL -XPOST -H "Content-Type: application/json" \
  -H "Host: geth.example.com" \
  -d '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":0}' \
  http://localhost:$(vagrant port --guest 80 node1)
```

`geth.example.com` is the default domain in this setup. You can change it by modifying the `ingress.domain_name` variable. For more details: [defaults/main.yaml](./roles/geth/defaults/main.yaml)

If you run the command above a few times, you can see the response will change sequentially because the default values will create a load balancer by NginX with the default load-balance method as `round-robin`. You can also change the load-balance method with the `ingress.lb_method` variable.

Please note that the upstream Geth nodes will be based on the hosts (`target` variable) you specify when running the ansible command line ([Makefile](./Makefile#L40)).

### Run as Docker

This project also supports running Geth nodes in Docker mode. You can do that by setting the `run_as_docker` variable to `true`. Or with the local environment, you can run with the command below:

```console
$ make ANSIBLE_ARGS='-v' RUN_AS_DOCKER=true test
```

Data will be saved when you change between `docker` and `without docker` mode.

### Wipe

You can wipe data and genesis.json by setting the `wipe` variable to `true`. By default, this will wipe all data and the `genesis.json` file. But you can specify the target to wipe with the `wipe_target` variable (Available options: `all`, `data`, `genesis`).

In the local environment:

```console
$ make ANSIBLE_ARGS='-v' WIPE=true WIPE_TARGET=data test
```

## Variable Support

Currently, important variables are all defined in _defaults/main.yaml_, I have also commented on all of them.

## Run on VMs

As I mentioned before, this project is experimental, but I also run it on VMs. You just need to copy the [inventory/test/main.yaml] to a new environment like `inventory/dev` and change the `hosts` in the `main.yaml`.

But there are a few variables that you need to change:

- `network_interface`: Intended for the internal network interface, which is used to communicate between nodes internally. This project uses this variable to detect the IP address of a node and register it into the upstream of the ingress config. For example, this value on a GCP VM is `ens4`.

## Limitations

- Currently, this project doesn't support Lighthouse yet.
- This only supports `Debian/Ubuntu`. Other OS will be supported in the future.

## References:

- [Ethereum Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network#private-networks)
- [NGINX Load Balancer](https://docs.nginx.com/nginx/admin-guide/load-balancer/http-load-balancer/)

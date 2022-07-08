## Kitabu Chain

### Prerequisites

#### Validator Hardware requirements

- Stable internet connection ($YOUR_IP:30303 should be publicly reachable)
- 2 CPU (`$ nproc`)
- 2 GB available RAM
- 40 GB Available space

_This step assumes you have root access on a Ubuntu (Tested on v22) based host OS_

```bash
$ apt update
$ apt install chrony curl git unzip
$ curl -fsSL https://get.docker.com | bash

# Docker now ships with docker-compose v2, you can make it available in path by adding the following line to your .bashrc
# export PATH="/usr/libexec/docker/cli-plugins:$PATH"

$ curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose

# If you have a firewall active, add 30303 (both TCP and UDP) to the allow list
```

#### Installing the OpenEthereum bin (optional, if you want to create a new keystore)
```bash
# This setp is only useful if you want to generate a new keystore with OpenEthereum.
# If you bring your own key or use geth, e.t.c. this step can be skipped
# x64 Linux only
$ wget https://github.com/openethereum/openethereum/releases/download/v3.3.5/openethereum-linux-v3.3.5.zip
$ unzip openethereum*
# assumes /usr/local/bin is in $PATH
$ sudo mv openethereum /usr/local/bin
$ openethereum --version
```

### Validator node setup

#### 1. Clone this repo

```bash
$ git clone https://gitlab.com/grassrootseconomics/kitabu-chain.git
$ cd kitabu chain
$ cd openethereum
# all commands after this step will be run in kitabu-chain/openethereum dir
```

All steps

#### 2. Obtain your private key (optional)

If you have an existing keystore file, rename it to `key` else create a new one:

```bash
$ openethereum account new --base-path=$(pwd)
$ mv keys/ethereum/UTC* ./key
$ rm -rf keys
```

Save the password you entered in the step above in a `password` file. After you complete creating the key, note the public address output (format `0x...`) somewhere.

#### 3. Setup environmental variables and other configs

```bash
$ cp .env.example .env
```

Edit the `.env` file:

- `EXT_IP`: Your server's external IP (`curl ifconfig.me`)
- `ACCOUNT`: Your private key's public address

Edit `docker-compose.yml` or `kitabu.toml` to tweak the Openethereum config as per your own preferences.

#### 4. Start the validator node

```bash
$ docker-compose up
#  or...
$ docker-compose up -d
```

### Reverse proxy setup (optional)

The `devops` folder contains a Caddy config to use as a reverse proxy to further control access to your validator node's API.

#### with your domain hosting provider:
create two A records, pointing to your server's public IP address:
* `rpc.YOURPUBLICDOMAIN`
* `ws.YOURPUBLICDOMAIN`

#### inside the `devops` folder:
```bash
$ cp Caddyfile.copyAndEdit Caddyfile
```
Edit the `Caddyfile` file:
- `.YOURPUBLICDOMAIN`: the  public domain that points to your server.
  
  
Bring Caddy up with:
```bash
$ docker-compose up -d
#  or...
$ docker-compose up -d
```

### Ethstats client (optional)

The `ethstats-client` folder contains a the statisics client that publishes to the Kitabu dashboard (https://stats.kitabu.sarafu.network/).

#### inside the `ethstats-client` folder:
```bash
$ cp .env.copyAndEdit .env
```
Edit the `.env` file:
- `YOURARBITRARYINSTANCENAME`: your chosen instance name (what you want to call your validator on the dashboard)


Bring the ethstats client up with:
```bash
$ docker-compose up -d
#  or...
$ docker-compose up -d
```

### Non Validator full node setup

Change the toml file to:

```toml
[parity]
chain = "./kitabu.json"
base_path = "./data"

[footprint]
tracing = "on"
pruning = "archive"
```

Ensure `kitabu.json` exists at the path declared above and then run:

```bash
openethereum --config=kitabu.toml --bootnodes=enode://4bf5f4d219fbe71e35f34e42b8df898f81a743563d87e52b2c6ea8080c607f7d5a02e8cf4f553a689a0f9ca73d6102721e51cd173351c85f8dae281e356bf5f0@51.15.48.58:30303,enode://3d58cc2d1394c7c75c8118b2c3105dc730ee4c2f3580e8a3042c9db6eafb47c4e47cd8702d2ee4e8d8de180859fedc4041f5078589223e5f74d1206fb1a2edf8@163.172.141.184:30303,enode://b5b5c80c93a96ff61762ed25072aabc02c8db4a19e973d59eefb6f1ad5dd1c5c1a485c97c3d96ec03135025ac717140d4375332cd5253c4ac1ccbe2f3ee571f6@142.93.38.53:30303
```

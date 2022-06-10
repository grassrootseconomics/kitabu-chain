## Kitabu Chain

### Prerequisites

_This step assumes you have root access on a Debian or Ubuntu based host OS_

```bash
$ apt update
$ apt install chrony curl git unzip
$ curl -fsSL https://get.docker.com | bash
$ curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
```

#### Installing the OpenEthereum bin
```bash
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
```

#### 2. Obtain your private key

If you have an existing keystore file, rename it to `key` else create a new one:

```bash
# wherever you have openethereum installed
$ openethereum account new --base-path=$(pwd)
$ mv keys/ethereum/UTC* ./key
$ rm -rf keys
```

Save the password of the key created above in a `password` file. Save the key's public address for the next step.

#### 3. Setup environmental variables and other configs

```bash
cp .env.example .env
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

#### 5. Reverse proxy setup

The `devops` folder contains a Caddy config to use as a reverse proxy to further control access to your validator node's API.

Replace `.yourdomain` in the `Caddyfile` and point it to your server IP.

#### 6. Ethstats client

Replace the missing values in the `.env` file i.e. WS_SECRET and INSTANCE_NAME (To what you want to call your validator).

Bring it up with:

`docker-compose up -d` inside the ethstats-client dir

### Non Validator node setup

Change the toml file to:

```toml
[parity]
chain = "./kitabu.json"
base_path = "./data"

[footprint]
tracing = "on"
pruning = "archive"
```

Use the same configs otherwise

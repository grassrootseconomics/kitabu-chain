## Kitabu Chain

### Prerequisites

_This step assumes you have root access on a Debian or Ubuntu based host OS_

```bash
$ apt update
$ apt install chrony curl git
$ curl -fsSL https://get.docker.com | bash
$ curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
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

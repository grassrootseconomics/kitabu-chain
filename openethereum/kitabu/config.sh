#!/bin/bash

templater_bin=../../aux/bash-templater/templater.sh

set +a
CONFIG_DIR=${CONFIG_DIR:-$(realpath $(pwd))}
DATA_DIR=${DATA_DIR:-${CONFIG_DIR}/data}
LOG_DIR=${LOG_DIR:-$DATA_DIR}
KEYSTORE_DIR=${DATA_DIR}/data/keys/kitabu_sarafu
EXTERNAL_IP=${EXTERNAL_IP:-127.0.0.1}

mkdir -vp $CONFIG_DIR
mkdir -vp $DATA_DIR
mkdir -vp $LOG_DIR
mkdir -vp $KEYSTORE_DIR
cp -v keyfile.json $KEYSTORE_DIR/

. $templater_bin kitabu.toml.template > kitabu.toml
set -a

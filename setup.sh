#!/bin/bash

# Start nodeos if it's not already running
if [ -z "$(ps | grep nodeos)" ]
then
  echo | nohup nodeos -e -p eosio --plugin eosio::wallet_api_plugin --plugin eosio::wallet_plugin --plugin eosio::producer_plugin --plugin eosio::history_plugin --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin --plugin eosio::http_plugin -d /mnt/dev/data --config-dir /mnt/dev/config --http-server-address=0.0.0.0:8888 --access-control-allow-origin=* --contracts-console > /root/nodeos.err 2> /root/nodeos.log &
fi

# Create wallet and show password
echo -n "Wallet name: "
read WALLET_NAME
WALLET_RES="$(cleos wallet create -n ${WALLET_NAME})"
WALLET_PWD="$(grep -oP '(?<=\")(.*)(?=\")' <<< "$WALLET_RES")"
echo Wallet password: ${WALLET_PWD}

# Import eosio default key for the eos-dev docker image into your wallet so
# that an account can be created
echo "Importing eosio key into the new wallet so that accounts can be created..."
echo 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3 | cleos wallet import --name ${WALLET_NAME}

# Create key and show public key
echo "Creating keys for the new account..."
WALLET_KEY_RES="$(cleos wallet create_key -n ${WALLET_NAME})"
WALLET_PUBK="$(grep -oP '(?<=\")(.*)(?=\")' <<< "$WALLET_KEY_RES")"
echo Wallet public key: ${WALLET_PUBK}

# Create account
echo -n "Account name: "
read ACCOUNT_NAME
cleos create account eosio ${ACCOUNT_NAME} ${WALLET_PUBK} ${WALLET_PUBK}

# Create and compile contract
echo Creating smart contract...
cd
eosiocpp -n hello
cd hello
eosiocpp -o hello.wast hello.cpp
eosiocpp -g hello.abi hello.cpp

# Deploy contract
cleos set contract ${ACCOUNT_NAME} . hello.wast hello.abi
cleos push action ${ACCOUNT_NAME} hi "[\"${ACCOUNT_NAME}\"]" -p ${ACCOUNT_NAME}

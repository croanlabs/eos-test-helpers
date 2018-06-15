#!/bin/bash

# Start nodeos if it's not already running
if [ -z "$(ps | grep nodeos)" ]
then
  echo | nohup nodeos -e -p eosio --plugin eosio::chain_api_plugin --plugin eosio::history_api_plugin > /root/nodeos.err 2> /root/nodeos.log &
fi

# Create wallet and show password
echo -n "Wallet name: "
read WALLET_NAME
WALLET_RES="$(cleos wallet create -n ${WALLET_NAME})"
WALLET_PWD="$(grep -oP '(?<=\")(.*)(?=\")' <<< "$WALLET_RES")"
echo Wallet password: ${WALLET_PWD}

# Create key and show public key
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

# EOS test helpers
The aim of this repository is to create a compilation of scripts to test your EOS development environment. These scripts are originally oriented to be executed on the eosio/eos-dev Docker image, but their execution is not limited to that environment as long as the dependencies are installed.

Please feel free to add your own scripts!

## Dependencies
The following EOS programs and tools are required to run the scripts:
+ nodeos
+ cleos
+ keosd
+ eosiocpp

## Instructions
### Running Docker EOS development image
```
sudo docker run --name nodeos -p 8888:8888 -p 9876:9876 -ti eosio/eos-dev /bin/bash
```
The image version can be specified by adding the version number to the image name. For example, to run the version ```v1.0.3``` just replace ```eosio/eos-dev``` by ```eosio/eos-dev:v1.0.3```. If no version is specified the latest version is used.

## Scripts
+ setup.sh
  + Run nodeos if it was not running already.
  + Create a wallet, generate a key and create an account.
  + Create a contract and deploy it to the blockchain.

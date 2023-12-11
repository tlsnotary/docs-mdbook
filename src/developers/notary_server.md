# Run a Notary Server

This guide shows you how to run a [notary server](https://github.com/tlsnotary/tlsn/tree/dev/notary-server) in an Ubuntu server instance.

## Using Cargo
1. Install required system dependencies
```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install libclang-dev pkg-config build-essential libssl-dev
```
2. Install rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```
3. Download notary server source code
```bash
 mkdir ~/src; cd ~/src
 git clone https://github.com/tlsnotary/tlsn.git
```
4. Run the server
```bash
cd tlsn/notary-server
cargo run --release
```
5. For more customisation of the server, please refer to the repo's [readme](https://github.com/tlsnotary/tlsn/blob/31708c080597b1e176cd5d892bfd44496bfdbf36/notary-server/README.md#using-cargo)

## Using Docker
1. Install docker following your preferred method [here](https://docs.docker.com/engine/install/ubuntu/)
2. Run the notary server docker image
```bash
docker run --init -p 127.0.0.1:7047:7047 ghcr.io/tlsnotary/notary-server:latest
```
3. For more customisation of the server, please refer to the repo's [readme](https://github.com/tlsnotary/tlsn/blob/31708c080597b1e176cd5d892bfd44496bfdbf36/notary-server/README.md#using-docker)

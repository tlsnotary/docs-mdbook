# Run a Notary Server

This guide shows you how to run a [notary server](https://github.com/tlsnotary/tlsn/tree/dev/notary-server) in an Ubuntu server instance.

## Configure Server Setting
All the following settings can be configured in the [config file](https://github.com/tlsnotary/tlsn/blob/dev/notary-server/config/config.yaml).

1. Before running a notary server you need the following files. The default dummy fixtures are for testing only and should never be used in production.

    | File | Purpose | File Type | Compulsory to change |
     ----- | ------- | ------------------ | -------------------- |
    | TLS private key | The private key used for the notary server's TLS certificate to establish TLS connections with provers | Compatible TLS private key in PEM format | Yes unless TLS is turned off |
    | TLS certificate | The notary server's TLS certificate to establish TLS connections with provers | Compatible TLS certificate in PEM format | Yes unless TLS is turned off |
    | Notary signature private key | The private key used for the notary server's signature on the generated transcript of the TLS sessions with provers | A P256 elliptic curve private key in PEM format | Yes |
    | Notary signature public key | The public key used for the notary server's signature on the generated transcript of the TLS sessions with provers | A matching public key (in PEM format) | Yes |
2. Expose the notary server port (specified in the config file) on your server networking setting
3. Optionally one can turn on [authorization](https://github.com/tlsnotary/tlsn/tree/dev/notary-server#authorization), or turn off [TLS](https://github.com/tlsnotary/tlsn/tree/dev/notary-server#optional-tls) if TLS is handled by an external setup


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
4. To configure the [server setting](#configure-server-setting), please refer to the `Using Cargo` section in the repo's [readme](https://github.com/tlsnotary/tlsn/blob/dev/notary-server/README.md#using-cargo)
5. Run the server
```bash
cd tlsn/notary-server
cargo run --release
```

## Using Docker

1. Install docker following your preferred method [here](https://docs.docker.com/engine/install/ubuntu/)
2. To configure the [server setting](#configure-server-setting), please refer to the `Using Docker` section in the repo's [readme](https://github.com/tlsnotary/tlsn/blob/dev/notary-server/README.md#using-docker)
3. Run the notary server docker image
```bash
docker run --init -p 127.0.0.1:7047:7047 ghcr.io/tlsnotary/notary-server:latest
```

# Run a Notary Server

This guide shows you how to run a [notary server](https://github.com/tlsnotary/tlsn/tree/main/notary/server) in an Ubuntu server instance.

## Configure Server Setting
All the following settings can be configured in the [config file](https://github.com/tlsnotary/tlsn/blob/main/notary/server/config/config.yaml).

1. Before running a notary server you need the following files. ⚠️ The default dummy fixtures are for testing only and should never be used in production.

    | File | Purpose | File Type | Compulsory to change | Sample Command |
     ----- | ------- | ------------------ | -------------------- | ------------- |
    | TLS private key | The private key used for the notary server's TLS certificate to establish TLS connections with provers | TLS private key in PEM format | Yes unless TLS is turned off | <Generated when creating CSR for your Certificate Authority, e.g. using [Certbot](https://certbot.eff.org/)> |
    | TLS certificate | The notary server's TLS certificate to establish TLS connections with provers | TLS certificate in PEM format | Yes unless TLS is turned off | <Obtained from your Certificate Authority, e.g. [Let's Encrypt](https://letsencrypt.org/)> |
    | Notary signature private key | The private key used for the notary server's signature on the generated transcript of the TLS sessions with provers | A P256 elliptic curve private key in PKCS#8 PEM format | Yes | `openssl genpkey -algorithm EC -out eckey.pem -pkeyopt ec_paramgen_curve:P-256 -pkeyopt ec_param_enc:named_curve` |
    | Notary signature public key | The public key used for the notary server's signature on the generated transcript of the TLS sessions with provers | A matching public key in PEM format | Yes | `openssl ec -in eckey.pem -pubout -out eckey.pub` |
2. Expose the notary server port (specified in the config file) on your server networking setting
3. Optionally one can turn on [authorization](https://github.com/tlsnotary/tlsn/tree/main/notary/server#authorization), or turn off [TLS](https://github.com/tlsnotary/tlsn/tree/main/notary/server#optional-tls) if TLS is handled by an external setup, e.g. reverse proxy, cloud setup


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
4. Switch to your desired [released version](https://github.com/tlsnotary/tlsn/releases), or stay in the `main` branch to use the latest version (⚠️ only prover of the same version is supported for now)
```bash
git checkout tags/<version>
```
5. To configure the [server setting](#configure-server-setting), please refer to the `Using Cargo` section in the repo's [readme](https://github.com/tlsnotary/tlsn/blob/main/notary/server/README.md#using-cargo)
6. Run the server
```bash
cd tlsn/notary/server
cargo run --release
```

## Using Docker

1. Install docker following your preferred method [here](https://docs.docker.com/engine/install/ubuntu/)
2. To configure the [server setting](#configure-server-setting), please refer to the `Using Docker` section in the repo's [readme](https://github.com/tlsnotary/tlsn/blob/main/notary/server/README.md#using-docker)
3. Run the notary server docker image of your desired version (⚠️ only prover of the same version is supported for now)
```bash
docker run --init -p 127.0.0.1:7047:7047 ghcr.io/tlsnotary/tlsn/notary-server:<version>
```

## API Endpoints
Please refer to the list of all HTTP APIs [here](./notary_server_api.html), and WebSocket APIs [here](https://github.com/tlsnotary/tlsn/tree/main/notary/server#websocket-apis).

## PSE Development Notary Server

> **_⚠️ WARNING:_** notary.pse.dev is hosted for development purposes only. You are welcome to use it for exploration and development; however, please refrain from building your business on it. Use it at your own risk.

The TLSNotary team hosts a public notary server for development, experimentation, and demonstration purposes. The server is currently open to everyone, provided that it is used fairly.

We host multiple versions of the notary server:

| Version       | Notary URL                            | Info/Status                                                                                                    | GitHub                                                                                     | Note                                          |
|---------------|---------------------------------------|----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|-----------------------------------------------|
| v0.1.0-alpha.6 | https://notary.pse.dev/v0.1.0-alpha.6 | [info](https://notary.pse.dev/v0.1.0-alpha.6/info)/[health](https://notary.pse.dev/v0.1.0-alpha.6/healthcheck) | [v0.1.0-alpha.6](https://github.com/tlsnotary/tlsn/tree/v0.1.0-alpha.6/notary/server)       | [Release notes](https://github.com/tlsnotary/tlsn/releases/tag/v0.1.0-alpha.6) |
| v0.1.0-alpha.5 | https://notary.pse.dev/v0.1.0-alpha.5 | [info](https://notary.pse.dev/v0.1.0-alpha.5/info)/[health](https://notary.pse.dev/v0.1.0-alpha.5/healthcheck) | [v0.1.0-alpha.5](https://github.com/tlsnotary/tlsn/tree/v0.1.0-alpha.5/notary-server)       | [Release notes](https://github.com/tlsnotary/tlsn/releases/tag/v0.1.0-alpha.5) |
| v0.1.0-alpha.4 | https://notary.pse.dev/v0.1.0-alpha.4 | [info](https://notary.pse.dev/v0.1.0-alpha.4/info)/[health](https://notary.pse.dev/v0.1.0-alpha.4/healthcheck) | [v0.1.0-alpha.4](https://github.com/tlsnotary/tlsn/tree/v0.1.0-alpha.4/notary-server)       | [Release notes](https://github.com/tlsnotary/tlsn/releases/tag/v0.1.0-alpha.4) |
| nightly       | https://notary.pse.dev/nightly        | [info](https://notary.pse.dev/nightly/info)/[health](https://notary.pse.dev/nightly/healthcheck)               | [dev](https://github.com/tlsnotary/tlsn/tree/dev/notary/server)                            |                                                |

For more details on the deployment, refer to this [GitHub Action](https://github.com/tlsnotary/tlsn/blob/main/.github/workflows/cd-server.yml).

To check the status of the notary server, visit the `healthcheck` endpoint at:
`https://notary.pse.dev/<version>/healthcheck`

### WebSocket Proxy Server

Because web browsers don't have the ability to make TCP connections directly, TLSNotary requires a WebSocket proxy to set up TCP connections when it is used in a browser. To facilitate the exploration of TLSNotary and to run the examples easily, the TLSNotary team hosts a public WebSocket proxy server. This server can be used to access the following whitelisted domains:

```
api.twitter.com:443
twitter.com:443
gateway.reddit.com:443
reddit.com:443
swapi.dev:443
api.x.com:443
x.com:443
discord.com:443
connect.garmin.com:443
uber.com:443
riders.uber.com:443
m.uber.com:443
```

You can utilize this WebSocket proxy with the following syntax:

```
wss://notary.pse.dev/proxy?token=<domain>
```

Replace `<domain>` with the domain you wish to access (for example, `swapi.dev`).
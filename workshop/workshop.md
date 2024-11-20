<figure>
    <img src="https://github.com/user-attachments/assets/64028fbf-ab6b-4266-90eb-5add1295204e" width=1280 />
</figure>

# TLSNotary Workshop

## Introduction

This workshop introduces you to TLSNotary, both in native Rust and in the browser.

**Workshop Objectives:**
* Understand the applications of TLSNotary.
* Learn the basics of attesting, proving, and verifying data using TLSNotary.

## Pre-Workshop Setup

To avoid network issues on conference Wi-Fi, please download the following dependencies in advance:
1. Clone repositories, get dependencies and build code
    ```shell
    # Clone Git Repositories:
    git clone -b dev https://github.com/tlsnotary/tlsn
    git clone https://github.com/tlsnotary/tlsn-plugin-boilerplate
    git clone https://github.com/tlsnotary/tlsn-js
    # Install websocket proxy
    cargo install wstcp
    # Build rust code (and download dependencies)
    cargo build  --manifest-path tlsn/Cargo.toml --release --examples
    # Build Javascript code (and download dependencies)
    npm install --prefix tlsn-plugin-boilerplate
    npm run --prefix tlsn-plugin-boilerplate build
    ```
    Note that this requires the [Rust](https://www.rust-lang.org/tools/install) and [NPM](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) toolchains.
2. [Install the TLSNotary Browser Plugin from the Chrome Web Store](https://chromewebstore.google.com/detail/tlsn-extension/gcfkkledipjbgdbimfpijgbkhajiaaph)


## Getting Started

In the first part of the workshop, we’ll begin with the basics. To keep things simple, we’ll use a local, single-computer setup wherever possible.

### Rust: Interactive Verification without a Trusted Notary

We’ll start by running the most basic TLSNotary setup.

![Overview Prover Verifier](https://hackmd.io/_uploads/ByCJOjF-Jg.svg)


We’ll run a local test server that serves the Prover JSON or HTML content. The Prover and Verifier will fetch this data via MPC, allowing the Prover to reveal parts of the JSON to the Verifier, who then verifies it.

We call this setup **Interactive Verification**.

> 🚀 The first examples use Rust. If you’re not a Rust dev, don’t worry—you don’t need to write Rust code yourself. 😇

#### Source Code

The source code is located at `crates/examples/interactive/interactive.rs` in the `tlsn` repository.

The setup has three main parts:

* `main()`: wires everything together.
* `prover(...)`:
  * Connects to the Verifier.
  * Connects to the TLS Server.
  * Performs MPC-TLS handshake.
  * Sends a request to the Server and waits for the response.
  * Redacts/reveals data and creates a proof for the Verifier.
* `verifier(...)`:
  * Verifies MPC-TLS and waits for (redacted) data.
  * Verifies disclosed data (hostname, content).

#### Start the Server

```shell
PORT=4000 cargo run --bin tlsn-server-fixture
```

#### Run the Example

To run the interactive example:

```shell
SERVER_PORT=4000 cargo run --release --example interactive
```

Expected log:

```log
Successfully verified https://test-server.io:4000/formats/html
Verified sent data:
GET https://test-server.io:4000/formats/html HTTP/1.1
host: test-server.io
connection: close
secret: 🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈🙈
```

For detailed debug information:

```shell
RUST_LOG=debug,yamux=info,uid_mux=info SERVER_PORT=4000 cargo run --release --example interactive
```

> ℹ️ **Note:** We run in `release` mode because `debug` mode is too slow to complete the TLS session before it times out.

#### Extra Tasks (optional)

- [ ] Experiment with different redactions.
- [ ] Try proving JSON content instead (`/formats/json`).

### Rust: Notarize with a Trusted Notary

Next, we’ll run the TLSNotary protocol with a Notary server blindly verifying the TLS session.

![Overview Notary](https://hackmd.io/_uploads/r1haDsKWkg.svg)


Leave the test server running.

Start the notary server:

```shell
cd crates/notary/server
cargo run -r -- --tls-enabled false
```

The `--tls-enabled false` argument disables TLS between the Prover and the Notary. We use it here to simplify the setup.

The process has three steps:

1. **Notarize** a request and response from the test server and obtain an attestation.
2. **Create a redacted, verifiable presentation** from the attestation.
3. **Verify the presentation.**

The term *presentation* aligns with [W3 Verifiable Credentials](https://www.w3.org/TR/vc-data-model/#dfn-verifiable-presentations).

#### 1. Notarize

Next create a presentation with:

```shell
SERVER_PORT=4000 cargo run --release --example attestation_prove
```

This notarizes a request and `json`-response from the test server and acquires an attestation. The result is written to two files: an attestation and the MPC secrets. In the next step the Prover can use these two files to create different presentations for the Verifier to verify.

#### 2. Create Presentation

```shell
cargo run --release --example attestation_present
```

In `crates/examples/attestation/present.rs`, inspect how certain content is revealed or concealed.

#### 3. Verify

Finally the verifier can verify the presentation:
```shell
cargo run --release --example attestation_verify
```
This will verify the presentation and print the disclosed data to the console.

Note that in a real world scenario, the Prover would send the Presentation to the Verifier, here we just used the filesystem.


#### Extra tasks (optional)

Try the above steps with different types of web content:
- [ ] **HTML**: Append `-- html` to the commands for each of the steps
- [ ] **Authenticated content**: Append `-- authenticated` to the commands for each of the steps. (This will add an authentication token to the request to access 'private' data).


### Browser: notarize with the Browser extension

Good job. Now that you have a better understanding of what is going on under the hood: Let's try TLSNotary in the Browser with our Browser Extension.

Running the TLSNotary protocol in the Browser needs something special. Browser extensions can not open TCP connections, and this is required to connect the Prover to the Server. So to run the Prover in a browser we need a workaround: a websocket proxy.

The easiest way to run a local websocket proxy is to use `wstcp`:
```shell
wstcp --bind-addr 127.0.0.1:55688 api.x.com:443
```
This command allows the browser to setup a TCP connection to `api.x.com` by talking to the websocket at port `55688`.

Next we need to configure the Browser Extension options to use the local notary and websocket proxy.

* Click the **Options** button in the Extension and make following changes
  * **Notary** API: Keep the default, this will use PSE's development notary server. Note that you can also use a local notary server, but make sure its version matches the version of the browser extension (i.e. `v0.1.0-alpha.7`)
  * **Proxy API**: `ws://localhost:55688`

> ℹ️ You can also use the [proxy server hosted by PSE](https://docs.tlsnotary.org/developers/notary_server.html#websocket-proxy-server). Note that this proxy server only supports a limited list of whitelisted domains. If you want to access other domains, you will need to run your own proxy server.

#### Notarize

Try either the Twitter or Discord plugin and follow the steps in UI. If everything works correctly, you should and up with a valid presentation. Click the **View Proof** button to check the verified presentation.

#### Extra items (optional)

- [ ] Instead of using a plugin, try to manually notarize a page as documented on https://docs.tlsnotary.org/quick_start/browser_extension.html
- [ ] Instead of using the plugin's presentation preview tool, download the presentation (called proof in the UI) and render it with https://explorer.tlsnotary.org instead.

## Notarize in teams

This part is optional but should be fun: team up with your neighbors and distribute roles: Server, Prover, Verifier and Notary. Can you make it work?

Make sure to open the required ports on your firewall.

### Notarize with a Trusted Notary

Distribute the roles and make sure to configure `NOTARY_HOST`, `NOTARY_PORT`,`SERVER_HOST` and `SERVER_PORT` to the correct values. Check `/crates/examples/attestation/prove.rs` for the details.


### Interactive verifier

For the interactive verifier you can use the *interactive verifier* demo from the <https://github.com/tlsnotary/tlsn-js> repo. The demo is in the `demo/interactive-demo` folder.

One team member starts the Verifier:
```bash
cd interactive-demo/verifier-rs; cargo run --release
```

And another team member runs the Prover. Make sure to configure the correct `VERIFIER_HOST` first:
```bash
cd interactive-demo/prover-rs; cargo run --release
```

- [ ] Make it work
- [ ] Check that the Verifier is not talking to the TLS server
- [ ] Check that the Verifier only sees what the prover wants to disclose.
- [ ] Try to make it break

## Building apps with TLSNotary

👍 Good job! We are progressing nicely and learning a lot.

The next topic is building web applications that use TLSNotary attestations.

First we will test a demonstration webapp that uses the browser extension to request an attestation of the user's Twitter profile.
Next we will build this plugin ourselves.

### Browser extension Connection API

Next topic is exploring a web application that verifies that you have a Twitter account and rewards you with a POAP if you do.

Visit <https://demo.tlsnotary.org> and walk through the steps.

You can verify what the web app is doing by reading the source code at <https://github.com/tlsnotary/tlsn-plugin-demo>.

You can find more information on the [Provider API in our documentation](https://docs.tlsnotary.org/extension/provider.html).

> ⚠️ **Note:** This demo allows for proving with any notary (so that you can use local notary to avoid stressing the network). In real world applications, please verify the attestation more carefully to make sure the attestations you receive are trustworthy.

### Browser extension plugins

```shell
git clone https://github.com/tlsnotary/tlsn-plugin-boilerplate
npm i
npm run build
```

After you run the above commands, the dist folder should now contain a `twitter_profile.tlsn.wasm` file. This is a plugin that can be loaded in the Extension.

Before we add the plugin into the extension, remove the existing Twitter plugin to avoid confusion (Hover the plugin and click the red cross in the top right of the extension).

Next click **Add plugin** and select the `twitter_profile.tlsn.wasm` file in the `dist` folder.

Next try the plugin by clicking it in the extension and following the steps in the sidebar.

You can find more information at https://docs.tlsnotary.org/extension/plugins.html


> ℹ️ Note: Because we use Extism to build the TLSNotary Extension plugins, you can also write plugins in Rust. See https://github.com/tlsnotary/tlsn-plugin-boilerplate/tree/main/examples/twitter_profile_rs for an example.

### Play Time

You now have experimented with the basic building blocks. Next step is to build your own applications with TLSNotary.

Think of what Web2 data you'd like to unlock: Private message, identity providers, reputation sources, financial information, ...
Build a custom plugin or develop a complete webapp with TLSNotary. The TLSNotary team is here to help you! ❤️
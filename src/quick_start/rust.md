# Rust Quick Start

This Quick Start will show you how to use TLSNotary in a native Rust application.

## Requirements

Before we start, make sure you have cloned the `tlsn` repository and have a recent version of Rust installed.

###  Clone the TLSNotary Repository

Clone the `tlsn` repository (defaults to the `main` branch, which points to the latest release):

```shell
git clone https://github.com/tlsnotary/tlsn.git
```

Next open the `tlsn` folder in your favorite IDE.

### Install Rust

If you don't have Rust installed yet, you can install it using [rustup](https://rustup.rs/):

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

To configure your current shell, run:
```shell
source "$HOME/.cargo/env"
```

## Simple Example: Notarizing Public Data from example.com <a name="rust-simple"></a>

This example demonstrates the simplest possible use case for TLSNotary:
1. Fetch <https://example.com/> and acquire an attestation of its content.
2. Create a verifiable presentation using the attestation, while redacting the value of a header.
3. Verify the presentation.

### 1. Notarize <https://example.com/>

Run the `prove` binary:
```shell
cd crates/examples/attestation
cargo run --release --example attestation_prove
```

If the notarization was successful, you should see this output in the console:

```log
Starting an MPC TLS connection with the server
Got a response from the server
Notarization completed successfully!
The attestation has been written to `example.attestation.tlsn` and the corresponding secrets to `example.secrets.tlsn`.
```

If you want to see more details, you can run the prover with extra logging:
```shell
RUST_LOG=DEBUG,uid_mux=INFO,yamux=INFO cargo run --release --example attestation_prove
```

⚠️ In this simple example the `Notary` server is automatically started in the background. Note that this is for demonstration purposes only. In a real world example, the notary should be run by a trusted party. Consult the [Notary Server Docs](https://docs.tlsnotary.org/developers/notary_server.html) for more details on how to run a notary server.

### 2. Build a verifiable presentation

This will build a verifiable presentation with the `User-Agent` header redacted from the request. This presentation can be shared with any verifier you wish to present the data to.

Run the `present` binary.

```shell
cargo run --release --example attestation_present
```

If successful, you should see this output in the console:

```log
Presentation built successfully!
The presentation has been written to `example.presentation.tlsn`.
```

### 3. Verify the presentation

This will read the presentation from the previous step, verify it, and print the disclosed data to console.

Run the `verify` binary.

```shell
cargo run --release --example attestation_verify
```

If successful, you should see this output in the console:

```log
Verifying presentation with {key algorithm} key: { hex encoded key }

**Ask yourself, do you trust this key?**

-------------------------------------------------------------------
Successfully verified that the data below came from a session with example.com at 2024-10-03 03:01:40 UTC.
Note that the data which the Prover chose not to disclose are shown as X.

Data sent:
...
```

⚠️ Notice that the presentation comes with a "verifying key". This is the key the Notary used when issuing the attestation that the presentation was built from. If you trust the Notary, or more specifically the verifying key, then you can trust that the presented data is authentic.

<!-- TODO: when explorer is updated -->
<!--
You can also use <https://explorer.tlsnotary.org/> to inspect your proofs. Open <https://explorer.tlsnotary.org/> and drag and drop `example.presentation.tlsn` from your file explorer into the drop zone. [Notary public key](https://github.com/tlsnotary/tlsn/blob/main/crates/notary/server/fixture/notary/notary.pub) 

![Proof Visualization](images/explorer.png)

Redacted bytes are marked with `X` characters.

![Proof Redacted](images/explorer_redacted.png)
-->

<!-- TODO: interactive verifier (p2p) example -->

<!-- ### (Optional) Extra Experiments

Feel free to try these extra challenges:

- [ ] Modify the `server_name` (or any other data) in `simple_proof.json` and verify that the proof is no longer valid.
- [ ] Modify the `build_proof_with_redactions` function in `simple_prover.rs` to redact more or different data. -->

## Notarizing Private Information: Discord Message<a name="rust-discord"></a>

Next, we will use TLSNotary to generate a proof of private information: a private Discord DM.

We will also use an explicit (locally hosted) notary server this time.

### 1. Start a Local Notary Server

The notary server used in this example is more functional compared to the (implicit) simple notary service used in the example above. This notary server should actually be run by the Verifier or a neutral party. To make things simple, we run everything on the same machine.

1. Edit the notary server config file (`crates/notary/server/config/config.yaml`) to turn off TLS so that self-signed certificates can be avoided (⚠️ this is only for local development purposes — TLS must be used in production).
   ```yaml
    tls:
        enabled: false
        ...
   ```
2. Run the notary server:
   ```shell
   cd crates/notary/server
   cargo run --release
   ```

The notary server will now be running in the background waiting for connections.

Keep it running and open a new terminal.

### 2. Get Authorization Token and Channel ID

Before we can notarize a Discord message, we need some parameters in a `.env` file.

In the `tlsn/examples/discord` folder, copy the `.env.example` file and name it `.env`.

In this `.env`, we will input the `USER_AGENT`, `AUTHORIZATION` token, and `CHANNEL_ID`.

| Name          | Example                                                                            | Location                                    |
| ------------- | ---------------------------------------------------------------------------------- | ------------------------------------------- |
| USER_AGENT    | `"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/116.0"` | Look for `User-Agent` in request headers    |
| AUTHORIZATION | `"MTE1NDe1Otg4N6NxNjczOTM2OA.GYbUBf.aDtcMUKDOmg6C2kxxFtlFSN1pgdMMBtpHgBBEs"`       | Look for `Authorization` in request headers |
| CHANNEL_ID    | `"1154750485639745567"`                                                            | URL                                         |

You can obtain these parameters by opening [Discord](https://discord.com/channels/@me) in your browser and accessing the message history you want to notarize.

> **_NOTE:_** ⚠️ Please note that notarizing only works for short transcripts at the moment, so choose a contact with a short history.

Next, open the **Developer Tools**, go to the **Network** tab, and refresh the page. Then, click on **Search** and type `/api` to filter results to Discord API requests. From there, you can copy the needed information into your `.env` as indicated above.

You can find the `CHANNEL_ID` directly in the URL:

`https://discord.com/channels/@me/{CHANNEL_ID)`

![Discord Authentication Token](./images/discord_authentication_token.png)

### 3. Notarize
In this tlsn/examples/discord folder, run the following command:

```sh
RUST_LOG=DEBUG,uid_mux=INFO,yamux=INFO cargo run --release --example discord_dm
```

If everything goes well, you should see output similar to the following:

```log
...
2024-06-26T08:49:47.017439Z DEBUG connect:tls_connection: tls_client_async: handshake complete
2024-06-26T08:49:48.676459Z DEBUG connect:tls_connection: tls_client_async: server closed connection
2024-06-26T08:49:48.676481Z DEBUG connect:commit: tls_mpc::leader: committing to transcript
2024-06-26T08:49:48.676503Z DEBUG connect:tls_connection: tls_client_async: client shutdown
2024-06-26T08:49:48.676466Z DEBUG discord_dm: Sent request
2024-06-26T08:49:48.676550Z DEBUG discord_dm: Request OK
2024-06-26T08:49:48.676598Z DEBUG connect:close_connection: tls_mpc::leader: closing connection
2024-06-26T08:49:48.676613Z DEBUG connect: tls_mpc::leader: leader actor stopped
2024-06-26T08:49:48.676618Z DEBUG discord_dm: [
  {
    "attachments": [],
    ...
    "channel_id": "1154750485639745567",
    ...
  }
]
2024-06-26T08:49:48.678621Z DEBUG finalize: tlsn_prover::tls::notarize: starting finalization
2024-06-26T08:49:48.680839Z DEBUG finalize: tlsn_prover::tls::notarize: received OT secret
2024-06-26T08:49:50.004432Z  INFO finalize:poll{role=Client}:handle_shutdown: uid_mux::yamux: mux connection closed
2024-06-26T08:49:50.004448Z  INFO finalize:poll{role=Client}: uid_mux::yamux: connection complete
2024-06-26T08:49:50.004583Z DEBUG discord_dm: Notarization complete!
```

<!-- TODO: update explorer -->
<!-- ### Verify

Verify the proof by dropping the JSON file into <https://explorer.tlsnotary.org/> or by running:

```shell
cargo run --release --example discord_dm_verifier
``` -->

🍾 Great job! You have successfully used TLSNotary in Rust.
<!-- 
### (Optional) Notarize More Private Data

If the examples above were too easy for you, try to notarize data from other websites such as:

- [ ] Amazon purchase
- [ ] Twitter DM (see <https://github.com/tlsnotary/tlsn/blob/main/tlsn/examples/twitter/README.md>)
- [ ] LinkedIn skill
- [ ] Steam accomplishment
- [ ] Garmin Connect achievement
- [ ] AirBnB score
- [ ] Tesla ownership -->

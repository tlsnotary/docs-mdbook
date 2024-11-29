# FAQ

- [Doesn't TLS allow a third party to verify data authenticity?](#faq1)
- [How exactly does a Verifier participate in the TLS connection?](#faq2)
- [What are the trust assumptions of the TLSNotary protocol?](#faq3)
- [What is the role of a Notary?](#faq4)
- [Is the Notary an essential part of the TLSNotary protocol?](#faq5)
- [Which TLS versions are supported?](#faq6)
- [What is the overhead of using the TLSNotary protocol?](#faq7)
- [Does TLSNotary use a proxy?](#faq8)
- [Why does my session time out?](#faq9)
- [How to run TLSNotary with extra logging?](#faq10)
- [How do I troubleshoot connection issues?](#faq11)
- [Does TLSNotary Solve the Oracle Problem?](#faq12)
- [What is a presentation in TLSNotary?](#faq13)


### Doesn't TLS allow a third party to verify data authenticity? { #faq1 }

No, it does not. TLS is designed to guarantee the authenticity of data **only to the participants** of the TLS connection. TLS does not have a mechanism to enable the server to "sign" the data.

The TLSNotary protocol overcomes this limitation by making the third-party `Verifier` a participant in the TLS connection. 

### Why is it necessary to add a verifier to the TLS connection? { #faq2 }

One may wonder why the `Prover` can not simply generate a proof of the TLS connection locally without the help of another party.

This is not possible because of the way TLS is designed. Specifically, TLS utilizes symmetric-key cryptography with message authentication codes (MACs). As a consequence the TLS client, i.e. the `Prover`, 
knows the secret key the `Server` uses to authenticate data and can trivially generate fake transcripts locally. Introducing another party into the connection mitigates this problem.

### How exactly does a Verifier participate in the TLS connection? { #faq3 }

The `Verifier` collaborates with the `Prover` using secure multi-party computation (MPC). There is no requirement for the `Verifier` to monitor or to access the `Prover's` TLS connection. The `Prover` is the one who communicates with the server.

### What are the trust assumptions of the TLSNotary protocol? { #faq4 }

The protocol does not have trust assumptions. In particular, it does not rely on secure hardware or on the untamperability of the communication channel.

The protocol does not rely on participants to act honestly. Specifically, it guarantees that, on the one hand, a malicious `Prover` will not be able to convince the `Verifier` of the authenticity of false data, and, on the other hand, that a malicious `Verifier` will not be able to learn the private data of the `Prover`.

### What is the role of a Notary? { #faq5 }

In some scenarios where the `Verifier` is unable to participate in a TLS connection, they may choose to delegate the verification of the online phase of the protocol to an entity called the `Notary`.

Just like the `Verifier` would ([see FAQ above](#faq2)), the `Notary` collaborates with the `Prover` using MPC to enable the `Prover` to communicate with the server. At the end of the online phase, the `Notary` produces an attestation trusted by the `Verifier`. Then, in the offline phase, the `Verifier` is able to ascertain data authenticity based on the attestation.

### Is the Notary an essential part of the TLSNotary protocol? { #faq6 }

No, it is not essential. The `Notary` is an optional role which we introduced in the `tlsn` library as a convenience mode for `Verifiers` who choose not to participate in the TLS connection themselves.

For historical reasons, we continue to refer to the protocol between the `Prover` and the `Verifier` as the "TLSNotary" protocol, even though the `Verifier` may choose not to use a `Notary`.

### Which TLS versions are supported? { #faq7 }

We support TLS 1.2, which is an almost-universally deployed version of TLS on the Internet. 
There are no immediate plans to support TLS 1.3. Once the web starts to transition away from TLS 1.2, we will consider adding support for TLS 1.3 or newer.

### What is the overhead of using the TLSNotary protocol? { #faq8 }

Due to the nature of the underlying MPC, the protocol is bandwidth-bound. We are in the process of implementing more efficient MPC protocols designed to decrease the total data transfer.

With the upcoming protocol upgrade planned for 2025, we expect the `Prover's` **upload** data overhead to be:


~25MB (a fixed cost per one TLSNotary session) + ~10 MB per every 1KB of outgoing data + ~40KB per every 1 KB of incoming data.

In a concrete scenario of sending a 1KB HTTP request followed by a 100KB response, the `Prover's` overhead will be:

25 + 10 + 4 = ~39 MB of **upload** data.

### Does TLSNotary use a proxy? { #faq9 }

A proxy is required only for the browser extension because browsers do not allow extensions to open TCP connections. Instead, our extension opens a websocket connection to a proxy (local or remote) which opens a TCP connection with the server. Our custom TLS client is then attached to this connection and the proxy only sees encrypted data.

[PSE hosts a WebSocket proxy](https://docs.tlsnotary.org/developers/notary_server.html#websocket-proxy-server) that you can use for development and experimentation. Note that this proxy supports only a limited [whitelist of domains](https://docs.tlsnotary.org/developers/notary_server.html#websocket-proxy-server). For other domains, you can easily run your own local WebSocket by following [these steps](https://docs.tlsnotary.org/quick_start/browser_extension.html#websocket-proxy).

### Why does my session time out? { #faq10 }

If you are experiencing slow performance or server timeouts, make sure you are building with the `--release` profile. Debug builds are significantly slower due to extra checks. Use:
```
cargo run --release
```
### How to run TLSNotary with extra logging? { #faq11 }

To get deeper insights into what TLSNotary is doing, you can enable extra logging with `RUST_LOG=debug` or `RUST_LOG=trace`. This will generate a lot of output, as it logs extensive network activity. It’s recommended to filter logs for better readability. The recommended configuration is:
```
RUST_LOG=trace,yamux=info,uid_mux=info cargo run  --release
```

In the Browser Extension you change the logging level via **Options > Advanced > Logging Level**

### How do I troubleshoot connection issues? { #faq12 }

If a TLSNotary request fails, first ensure that the request works independently of TLSNotary by testing it with tools like `curl`, Postman, or another HTTP client. This helps rule out any server or network issues unrelated to TLSNotary.

Next, confirm that your request includes the necessary headers:
- `Accept-Encoding: identity` to avoid compressed responses.
- `Connection: close` to ensure the server closes the connection after the response.

If the issue persists, [enable extra logging](#faq11) with `RUST_LOG=debug` or `RUST_LOG=trace` for deeper insights into what TLSNotary is doing.

If you are connecting through a WebSocket proxy (e.g., in the browser extension), double-check that the WebSocket proxy connects to the intended domain. Note that PSE's public WebSocket proxy only supports a limited [whitelist](https://docs.tlsnotary.org/developers/notary_server.html#websocket-proxy-server). If you use a local proxy, make sure the domain is correct.

### Does TLSNotary Solve the Oracle Problem? { #faq13 }

No, the TLSNotary protocol does not solve the "Oracle Problem." The Oracle Problem refers to the challenge of ensuring that off-chain data used in blockchain smart contracts is trustworthy and tamper-proof. While TLSNotary allows a Prover to cryptographically authenticate TLS data to a designated Verifier, trust is still required in the designated Verifier when it attests to the verified data on-chain. Therefore, this is not a trustless, decentralized solution to the Oracle Problem.

TLSNotary can be used to bring data on-chain, but when the stakes are high, it is recommended to combine TLSNotary with a dedicated oracle protocol to mitigate these risks. Multiple projects are currently exploring the best solutions.

### What is a presentation in TLSNotary? { #faq14 }

In TLSNotary, a **presentation** refers to data shared by the Prover to selectively reveal specific parts of the TLS data committed to earlier during the attestation phase. By using these earlier commitments, the Prover can choose to disclose only particular segments of the TLS data while keeping other parts hidden or redacted. This enables a flexible and controlled way to share proofs, ensuring that sensitive information remains private.

The term “presentation” is inspired by similar terminology in the [W3C Verifiable Credentials standard](https://www.w3.org/TR/vc-data-model/#dfn-verifiable-presentations).
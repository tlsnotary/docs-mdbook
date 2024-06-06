# FAQ

- [Doesn't TLS allow a third party to verify data authenticity?](#faq1)
- [How exactly does a Verifier participate in the TLS connection?](#faq2)
- [What are the trust assumptions of the TLSNotary protocol?](#faq3)
- [What is the role of a Notary?](#faq4)
- [Is the Notary an essential part of the TLSNotary protocol?](#faq5)
- [Which TLS versions are supported?](#faq6)
- [What is the overhead of using the TLSNotary protocol?](#faq7)


### Doesn't TLS allow a third party to verify data authenticity? { #faq1 }

No, it does not. TLS is designed to guarantee the authenticity of data **only to the participants** of the TLS connection. TLS does not have a mechanism to enable the server to "sign" the data.

The TLSNotary protocol overcomes this limitation by making the third-party `Verifier` a participant in the TLS connection. 

### How exactly does a Verifier participate in the TLS connection? { #faq2 }

The `Verifier` collaborates with the `Prover` using secure multi-party computation (MPC). There is no requirement for the `Verifier` to monitor or to access the `Prover's` TLS connection. The `Prover` is the one who communicates with the server.

### What are the trust assumptions of the TLSNotary protocol? { #faq3 }

The protocol does not have trust assumptions. In particular, it does not rely on secure hardware or on the untamperability of the communication channel.

The protocol does not rely on participants to act honestly. Specifically, it guarantees that, on the one hand, a malicious `Prover` will not be able to convince the `Verifier` of the authenticity of false data, and, on the other hand, that a malicious `Verifier` will not be able to learn the private data of the `Prover`.

### What is the role of a Notary? { #faq4 }

In some scenarios where the `Verifier` is unable to participate in a TLS connection, they may choose to delegate the verification of the online phase of the protocol to an entity called the `Notary`.

Just like the `Verifier` would ([see FAQ above](#faq2)), the `Notary` collaborates with the `Prover` using MPC to enable the `Prover` to communicate with the server. At the end of the online phase, the `Notary` produces an attestation trusted by the `Verifier`. Then, in the offline phase, the `Verifier` is able to ascertain data authenticity based on the attestation.

### Is the Notary an essential part of the TLSNotary protocol? { #faq5 }

No, it is not essential. The `Notary` is an optional role which we introduced in the `tlsn` library as a convenience mode for `Verifiers` who choose not to participate in the TLS connection themselves.

For historical reasons, we continue to refer to the protocol between the `Prover` and the `Verifier` as the "TLSNotary" protocol, even though the `Verifier` may choose not to use a `Notary`.

### Which TLS versions are supported? { #faq6 }

We support TLS 1.2, which is an almost-universally deployed version of TLS on the Internet. 
There are no immediate plans to support TLS 1.3. Once the web starts to transition away from TLS 1.2, we will consider adding support for TLS 1.3 or newer.

### What is the overhead of using the TLSNotary protocol? { #faq7 }

Due to the nature of the underlying MPC, the protocol is bandwidth-bound. We are in the process of implementing more efficient MPC protocols designed to decrease the total data transfer.

With the upcoming protocol upgrade planned for 2025, we expect the `Prover's` **upload** data overhead to be:

~25MB (a fixed cost per one TLSNotary session) + ~10 MB per every 1KB of outgoing data + ~40KB per every 1 KB of incoming data.

In a concrete scenario of sending a 1KB HTTP request followed by a 100KB response, the `Prover's` overhead will be:

25 + 10 + 4 = ~39 MB of **upload** data.

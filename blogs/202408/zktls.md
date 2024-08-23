# Terminology Matters: Why We Use MPC-TLS Attestations and Not zkTLS "Proofs"

**TL;DR:**  
Terminology matters, especially in the world of cryptography. In this post, we explain why **MPC-TLS attestations** are the preferred choice over *zkTLS "proofs"* within the context of TLSNotary. zkTLS is a misnomer.


## TLS and TLSNotary: A Brief Overview

**TLS (Transport Layer Security)** is the protocol that underpins much of the secure communication on the internet. It is the "s" in https. TLS ensures that data sent between a client and server is encrypted and remains private. However, unless the data is cryptographically signed at the source, traditional TLS doesn't offer a straightforward way to prove to a third party what data was exchanged.

**TLSNotary** is a tool designed to solve this problem by implementing an **MPC-TLS (Multi-Party Computation TLS)** protocol. In TLSNotary, both the Prover and the Verifier cooperate to establish a TLS connection, ensuring that the data exchanged is authentic. Through this collaboration, both parties receive cryptographic guarantees about the data’s authenticity and integrity. On the server’s side, this looks like a normal TLS session. TLSNotary is gaining popularity among developers for its ability to provide verifiable evidence of interactions with a server, ensuring that the data remains trustworthy for both parties involved. TLSNotary also protects the privacy of the user, but that is beyond the scope of this blog post.

## MPC or ZK? What’s the Difference?

**MPC (Multi-Party Computation)** and **ZK (Zero-Knowledge)** are two cryptographic techniques often mentioned together, but they serve different purposes.

**MPC** allows multiple parties to jointly compute a function over their inputs while keeping those inputs private. In the context of TLSNotary, MPC is used to perform a TLS handshake so both the Prover and the Verifier each have a key share. They need to cooperate to encrypt requests and decrypt responses with TLS's symmetric encryption. Through this collaboration, both parties receive cryptographic guarantees about the data’s authenticity and integrity. Additionally, during the MPC-TLS process, the Verifier only sees encrypted information, thus protecting the user’s privacy.

**ZK proofs** enable one party to prove to another that a statement is true without revealing any other information. Prefixing "zk" to a term is fashionable nowadays; however, **zkTLS** as a term is a misnomer. **True zero-knowledge proofs of TLS sessions are not feasible today**—TLS relies on interactive, stateful communication, which is too complex to fit into zk circuits.

TLSNotary uses ZK technology, but the main driver is MPC.

## Attestations vs. Proofs

When we talk about **proofs** in cryptography, we usually refer to something that is **publicly verifiable**; anyone with the proof can independently verify its validity without needing additional information. This is the strength of zero-knowledge proofs in general: they are self-contained and can be verified by anyone, anywhere.

On the other hand, an **attestation** is a statement made by one party to another about something that has occurred, and it often requires some level of trust in the party making the statement. In the case of MPC-TLS, the Verifier knows the TLS session was authentic, so it can attest to it. But the result is not something that everyone can independently verify without trust in the Verifier.

**Remark:** In the TLSNotary source code, the lines between a proof and an attestation blur. While the process generates something that is a proof to the Verifier, to anyone else, it is an attestation; they have to trust the Verifier’s claim about what happened.

## Onchain Attestations

When dealing with blockchain and onchain attestations, the Verifier cannot run onchain. This means that the attestation put onchain by the Prover (or the Verifier) is not a standalone proof but an attestation. Consumers of this information need to trust that there wasn't any collusion between the Prover and Verifier. TLSNotary can be used to build oracles, but it does not solve the **oracle problem**.

## Conclusion

In the end, terminology matters because it shapes our understanding and expectations of the technology we use. The term zkTLS might sound appealing, but it is inaccurate. TLS sessions are not proven using zero-knowledge proofs. Instead, TLSNotary favors the term **MPC-TLS attestations**.

By choosing the right terminology and understanding the implications of these choices, we can build more robust, efficient, and trustworthy cryptographic systems.

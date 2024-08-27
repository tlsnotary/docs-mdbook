# Terminology Matters: Why We Use MPC-TLS Attestations and Not zkTLS "Proofs"

We are seeing more and more occurrences of the term "zkTLS" [TODO: add links to Twitter]. The TLSNotary team believes this term is poorly chosen because it seems to imply that TLS sessions have all the typical properties of zero-knowledge proofs. In this blog post, we explain why we prefer the term **MPC-TLS Attestations** and choose not to use **zkTLS "Proofs."**

## TLS and TLSNotary: A Brief Overview

Before we dive into zkTLS vs. MPC-TLS, let’s first recap TLS and TLSNotary.

**TLS (Transport Layer Security)** is the protocol that underpins much of the secure communication on the internet. It is the “s” in https. TLS ensures that data sent between a client and server is encrypted and remains private. However, unless the data is cryptographically signed at the source, traditional TLS doesn’t offer a straightforward way to prove to a third party what data was exchanged.

[TODO: add TLSNotary diagram here later]

**TLSNotary** is a tool designed to solve this problem by implementing an **MPC-TLS (Multi-Party Computation TLS)** protocol. In TLSNotary, two parties—a Prover and a Verifier—cooperate to establish a TLS connection and retrieve authenticated data from a server. Through this collaboration, both parties receive cryptographic guarantees about the data’s authenticity and integrity. On the server’s side, this looks like a normal TLS session.

TLSNotary is gaining popularity among developers for its ability to provide verifiable evidence of interactions with a server, ensuring that the data remains trustworthy for both parties involved. TLSNotary also protects the privacy of the user, but that is beyond the scope of this blog post.

## Proofs vs. Attestations

When we talk about **proofs** in cryptography, we usually refer to something that is **publicly verifiable**—anyone with the proof can independently verify its validity without needing additional information. Publicly verifiable proofs are often associated with zero-knowledge proofs (ZKPs) and allow anyone to verify the proof without needing to trust any specific party. These systems are highly desirable but unfortunately not always feasible.

**Designated verifier** systems delegate verification to one verifier (or a coordinated group of verifiers). After successful verification, a verifier can **attest** to the data for other parties by issuing a signed **attestation**. This approach requires trust in the designated verifier’s integrity.

In the case of MPC-TLS, the Verifier knows the TLS session was authentic, so it can attest to it. However, the result is not something that everyone can independently verify without trust in the Verifier.

**Remark:** In the TLSNotary source code, the lines between a proof and an attestation can seem confusing. While TLSNotary generates something that is a proof to the Verifier, to anyone else, it is an attestation.

[TODO embed https://x.com/sinu_eth/status/1827135565185401239 here]

## Onchain Attestations

The Verifier cannot run onchain. The Verifier must be online simultaneously with both the Prover and the Server. This means that the attestation put onchain by the Prover (or the Verifier) is not a standalone proof but an attestation. And because an attester could attest to (or sign) whatever it wants, consumers of this information need to trust the attester. TLSNotary can be used to build oracles, but it does not solve the **oracle problem**.

## Conclusion

In the end, terminology matters because it shapes our understanding and expectations of the technology we use.

The term zkTLS might sound appealing, but it is confusing. The "zk" prefix in zkTLS seems to imply public verifiability, which is not the case. This is the reason we prefer **MPC-TLS Attestations** instead.
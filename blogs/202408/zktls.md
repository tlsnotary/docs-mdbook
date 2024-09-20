# Does TLSNotary Produce "Proofs" or "Attestations"?

Recently, the term ["zkTLS"](https://x.com/search?q=zktls) has become very popular on Crypto Twitter. The "zk" prefix suggests a combination of TLS with zk-SNARKs (Zero-Knowledge Succinct Non-Interactive Arguments of Knowledge), implying that the protocol would be publicly verifiable.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Incalculable levels of public confusion caused by a catchy prefix <a href="https://t.co/2OSyWwHQqN">pic.twitter.com/2OSyWwHQqN</a></p>&mdash; sinu (@sinu_eth) <a href="https://twitter.com/sinu_eth/status/1827135565185401239?ref_src=twsrc%5Etfw">August 24, 2024</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

To avoid confusion, this post explains how TLSNotary achieves verifiable TLS sessions. Spoiler: **TLSNotary's output is not a publicly verifiable proof; it is an attestation**.

Before diving deeper into TLSNotary, let’s first recap TLS itself.

**TLS (Transport Layer Security)** is the protocol that underpins much of the secure communication on the Internet. It is the “s” in HTTPS. TLS ensures that data sent between a client and server is encrypted and remains private. However, unless the data is cryptographically signed at the source, traditional TLS doesn’t offer a straightforward way to prove to a third party what data was exchanged.

![Overview](./overview1.svg)

**TLSNotary** is a tool designed to solve this problem by implementing an **MPC-TLS (Multi-Party Computation TLS)** protocol. In TLSNotary, two parties—a Prover and a Verifier—cooperate to establish a TLS connection and retrieve authenticated data from a server. Through this collaboration, both parties receive cryptographic guarantees about the data’s authenticity and integrity. From the server’s perspective, this looks like a normal TLS session. TLSNotary also protects the privacy of the Prover (aka the "user"), but that is beyond the scope of this blog post.

But can an external party **trustlessly** verify the data from a TLS connection? No, they can't. Their only option is to act as a Verifier in the TLSNotary protocol to obtain their own cryptographic guarantees. However, in many cases, it’s more practical to delegate the verification to a trusted party and rely on their attestations.

## Proofs vs. Attestations

When one talks about **proofs** in cryptography, one usually refers to something that is **publicly verifiable**—anyone with the proof can independently verify its validity without needing additional information. Publicly verifiable proofs are often associated with zk-SNARKs and allow anyone to verify the proof without needing to trust any specific party. These systems are highly desirable but, unfortunately, not always feasible.

**Designated-verifier** systems delegate verification to one verifier (or a coordinated group of verifiers). After successful verification, a verifier can **attest** to the data for other parties by issuing a signed **attestation**. This approach requires trust in the designated verifier’s integrity.

![Overview](./overview2.svg)

In the case of MPC-TLS, the Verifier has cryptographic guarantees that the TLS session was authentic, so it can attest to it as the designated verifier. This is an attestation, not a publicly verifiable proof.

All TLS-verifying protocols that the TLSNotary team is aware of (and which do not modify the TLS protocol) are designated-verifier protocols.

**Remark:** In the TLSNotary source code, the lines between a proof and an attestation can seem confusing. It is useful to have the following mental model. First, a Prover generates a proof to prove statements about the TLS connection data to a Verifier. Then, based on that proof, the Verifier issues an attestation.

## On-Chain Attestations

The Verifier cannot operate on-chain, as it must be online simultaneously with both the Prover and the Server. However, an attestation can still be utilized on-chain. Since a Notary could potentially sign anything, consumers of this information must trust the Notary. While TLSNotary can be used to build blockchain oracles, it does not solve the **oracle problem**.

For most off-chain applications, a designated verifier is a perfectly suitable solution. In traditional settings, delegating verification to a trusted party is common and practical. Off-chain, trust can be established through legal agreements, reputation, or regulatory frameworks, making attestations sufficient for many use cases.

## The Ideal Solution

In a perfect world, all data served by TLS servers would be cryptographically signed, making it **natively verifiable** without any extra complexity. This would remove the need for solutions like TLSNotary altogether. However, today, there is **little incentive** for most servers to cryptographically sign their data. Many servers prefer to avoid the added responsibility and potential liability that signing entails. As a result, we don't yet live in a world where data is universally signed. Until that changes, **TLSNotary fills a crucial gap**, offering a practical, privacy-preserving, secure solution to verify data in the absence of widespread cryptographic signing.

## Conclusion

While the term "zkTLS" is catchy and suggests a fully trustless, publicly verifiable protocol, it's important to understand the nuances. **TLSNotary does not produce publicly verifiable proofs, but attestations from designated verifiers.** In many practical applications—especially offchain—the use of attestations is both sufficient and appropriate within existing trust models.
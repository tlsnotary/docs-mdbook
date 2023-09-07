# Introduction

## Data Provenance without Compromising Privacy, That is Why!

The Internet currently lacks effective, privacy-preserving **Data Provenance**. [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security), also known as the "s" in "https" 🔐 to the general public, ensures that data can be securely communicated between a server and a user. But how can this user credibly share this data with another user or server without compromising security, privacy, and control?

Enter TLSNotary: a protocol enabling users to export data securely from any website. Using Zero Knowledge Proof (ZKP) technology, this data can be selectively shared with others in a cryptographically verifiable manner.

TLSNotary makes data truly portable and allows a user, the `Prover`, to share it with another user, the `Verifier`, as they see fit.

## How Does the TLSNotary Protocol Work?

The TLSNotary protocol consists of 3 steps:
1. The `Prover` **requests** the data from the `Server` privately and securely.
2. The `Prover` **selectively discloses** the data to the `Verifier`.
3. The `Verifier` **verifies** the data.

![](./diagrams/overview3.svg)

### ① Multi-party TLS Request

TLSNotary works by adding a second party, the `Verifier`, to the usual TLS connection between the `Prover` and a `Server`. This `Verifier` is **not "[a man in the middle](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)"**. Instead, the `Verifier` participates in a **secure multi-party computation** (MPC) to jointly operate the TLS connection without seeing the data in plain text. The TLSNotary protocol is transparent to the `Server`. From the `Server`'s perspective, the `Prover`'s connection is a standard TLS connection.

<!-- - Transport Layer Security (TLS)
    - Encryption: hides data from third parties
    - Authentication: ensures that the parties exchanging information are who they claim to be
    - Integrity: verifies that data has not been forged or tampered with -->
### ② Selective Disclosure
By participating in MPC for TLS communication, the `Verifier` can validate the authenticity and integrity of the `Prover`'s `communication with the `Server`. If the `Prover` was honest, the `Verifier` accepts the encrypted transcript of the entire TLS session, which provides a means for the `Prover` to selectively prove the authenticity of arbitrary plain text sections of this transcript to the `Verifier`. In this **selective disclosure** the `Prover` can **redact sections**, thereby removing sensitive data and send a proof to the `Verifier` only containing a redacted transcript. This capability can be paired with Zero-Knowledge Proofs to prove properties of the redacted data without revealing the data itself.

### ③ Verification

The `Verifier` now validates the proof received from the `Prover`. The data origin can be verified by inspecting the `Server` certificate through trusted certificate authorities (CAs). The `Verifier` can now make assertions about the non-redacted content of the transcript.

### General-purpose TLS verifier

Since the validation of the TLS traffic does neither reveal anything about the plain text of the TLS session, nor about the `Server`, it is possible to outsource the traffic validation part, i.e. the MPC, to a general-purpose TLS verifier, which we call `Notary`, who signs the transcript and thus makes it portable. The `Prover` can now take this signed transcript, and selectively disclose sections to an application-specific verifier.

![](./png-diagrams/overview3.png)

So in this setting the original `Verifier` has been split into a TLS verifier, the `Notary`, and an application-specific `Verifier` for the disclosure part. The `Notary` can now engage in MPC for the notarization of transcripts for several different applications. In this case the `Notary` would cryptographically sign a transcript, which the `Prover` can use to generate a proof and then send both the transcript and the proof containing the selective disclosure to the `Verifier`. Note that this setup comes with the trust assumption for the `Verifier` that the `Notary` did not collude with the `Prover`.

## What Can TLSNotary Do?

TLSNotary can be used for various purposes. For example, you can use TLSNotary to prove that:
- you have access to an account on a web platform
- a website showed specific content on a certain date
- you have private information about yourself (address, birth date, health, etc.)
- you have received a money transfer using your online banking account without revealing your login credentials or sensitive financial information
- you received a private message from someone
- you were blocked from using an app
- you earned professional certificates

While TLSNotary can notarize publicly available data, it does not solve the "[oracle problem](https://ethereum.org/en/developers/docs/oracles/)". For this use case, existing oracle solutions are more suitable.

## Who is behind TLSNotary?

TLSNotary is developed by the [Privacy and Scaling Exploration (PSE)](https://pse.dev) research lab of the Ethereum Foundation. The PSE team is committed to conceptualizing and testing use cases for cryptographic primitives.

TLSNotary is not a new project; in fact, it has been around for [more than a decade](https://bitcointalk.org/index.php?topic=173220.0).

In 2022, TLSNotary was rebuilt from the ground up in [Rust](https://www.rust-lang.org/) incorporating state-of-the-art cryptographic protocols. This renewed version of the TLSNotary protocol offers enhanced security, privacy, and performance.

Older versions of TLSNotary, including PageSigner, have been archived due to a security vulnerability.

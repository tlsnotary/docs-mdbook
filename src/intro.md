# Introduction

## Data Provenance without Compromising Privacy, That is Why!

The Internet currently lacks effective, privacy-preserving **Data Provenance**. [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security), also known as the "s" in "https" 🔐 to the general public, ensures that data can be securely communicated between a server and a user. But how can this user credibly share this data with another user or server without compromising security, privacy, and control?

Enter TLSNotary: a protocol enabling users to export data securely from any website. Using Zero Knowledge Proof (ZKP) technology, this data can be selectively shared with others in a cryptographically verifiable manner.

TLSNotary makes data truly portable and allows a user, the `Prover`, to share it with another user, the `Verifier`, as they see fit.

## How Does the TLSNotary Protocol Work?

The TLSNotary protocol consists of 3 steps:
1. The `Prover` **requests** the data from the `Server`. The `Verifier` participates with secure and privacy-preserving *multi party computation (MPC)*.
2. The `Prover` **selectively discloses** the data to the `Verifier`.
3. The `Verifier` **verifies** the data.

![](./diagrams/overview4.svg)

### ① Multi-party TLS Request

TLSNotary works by including the `Verifier` in the usual TLS communication between the `Prover` and a `Server`. This `Verifier` is **not "[a man in the middle](https://en.wikipedia.org/wiki/Man-in-the-middle_attack)"**. Instead, the `Verifier` participates in a **secure multi-party computation** (MPC) to jointly operate the TLS connection without seeing the data in plain text. By participating in the MPC, the `Verifier` can validate the authenticity and integrity of the data the `Prover` received from the `Server`.

The TLSNotary protocol is transparent to the `Server`. From the `Server`'s perspective, the `Prover`'s connection is a standard TLS connection.

### ② Selective Disclosure

The TLSNotary protocol allows the `Prover` to selectively prove the authenticity of arbitrary parts of the data to the `Verifier`. In this **selective disclosure** phase, the `Prover` can **redact sections** from the plain text, thereby removing sensitive data. Next, the `Prover` sends the redacted data to the `Verifier`.

This capability can be paired with Zero-Knowledge Proofs to prove properties of the redacted data without revealing the data itself.

### ③ Data Verification

The `Verifier` now validates the proof received from the `Prover`. The data origin can be verified by inspecting the `Server` certificate through trusted certificate authorities (CAs). The `Verifier` can now make assertions about the non-redacted content of the transcript.

## TLS verification with a general-purpose Notary

Since the validation of the TLS traffic does neither reveal anything about the plain text of the TLS session, nor about the `Server`, it is possible to outsource the MPC TLS verification to a general-purpose TLS verifier ①, which we call a `Notary`. This `Notary` can sign, or *notarize* ②, the data and thus make it portable. The `Prover` can now take this signed transcript, and selectively disclose ③ sections to an application-specific verifier which verifies the data ④.

![](./png-diagrams/overview3.png)

In this setting the original `Verifier` has been split into a TLS verifier, the `Notary`, and an application-specific `Verifier` for the disclosure part. The `Notary` can now engage in MPC for the notarization of data for several different applications. In this case the `Notary` cryptographically signs the data from the Server. Next, the `Prover` can selectively disclose the data to a application specific `Verifier`. Note that this setup comes with the trust assumption for the `Verifier` that the `Notary` did not collude with the `Prover`.

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

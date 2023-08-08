# Signing the Session Header

The `Notary` signs the following artifacts known as a `Session Header`, thereby attesting to the authenticity of the plaintext from a TLS session. The `User` can then use the signed `Session Header` to prove data provenance to a third-party `Verifier`.

It's important to highlight that throughout the entire TLSNotary protocol, including this signing stage, the `Notary` does not gain knowledge of either the plaintext or the server with which the `User` communicated.

## Session Header

A `Session Header` consists of the following components:

### Server Ephemeral Public Key

In TLS, session keys are derived from a one-time per-TLS-session ephemeral public key. The server signs this key with its certificate and transmits both the key and the signature to the `User`.

Since the `Notary` remains unaware of the signature or the certificate, the server's identity is concealed. However, the `User` can disclose the server's identity to a `Verifier` by revealing the signature and the certificate.

### Plaintext Encodings

These are the [encodings](../../mpc/encodings.md) employed by the Notary to encode the plaintext.

Again, note that the `Notary` does not gain knowledge of the actual plaintext. The `Notary` transmits these encodings to the `User` using [Oblivious Transfer](/mpc/oblivious_transfer.md).

For efficiency, the `Notary` employs a small PRG seed to generate random plaintext encodings.

### Root of the Merkle Tree of Commitments

The root of the Merkle tree, where each leaf represents the `User`'s commitment to plaintext encodings.

### Commitment to the TLS Handshake Data

This represents the `User`'s commitment to various public data from the TLS handshake:
- Server certificate chain
- Signature over the `Server Ephemeral Public Key`, created using the `Server Certificate Chain`
- Client random
- Server random

### Time

Indicates the time when the Notary signed the `Session Header`.

### Total Bytes Sent and Received

The total amount of application data bytes that the `User` sent to and received from the server.

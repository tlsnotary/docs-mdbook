# Signing the session header

The `Notary` signs the following artifacts called a `Session Header` thereby attesting to the authenticity of the plaintext from a TLS session. The `User` can then use a signed `Session Header` to prove data provenance to a third-party `Verifier`.


We emphasize that throughout the whole TLSNotary protocol (including this signing stage), the `Notary` does not learn either the plaintext or the server which the `User` communicated with.



A `Session Header` consists of:

### Server ephemeral public key

In TLS the session keys are derived from a one-time per-TLS-session ephemeral public key. The server uses its certificate to sign this key and sends the key and the signature to the `User`.

Since the `Notary` does not know the signature or the certificate, he is unaware of the identity of the server. The `User`, on the other hand, can reveal the server's identity to a `Verifier` by revealing the signature and the certificate.

### Plaintext encodings
 
Encodings used by the Notary to encode the plaintext.

Note that the `Notary` did not learn the actual plaintext but sent these encodings to the `User` using [Oblivious Transfer](/mpc/oblivious_transfer.md).

For efficiency, the `Notary` used a small PRG seed to generate random plaintext encodings.

### Root of the Merkle tree of commitments

The root of the Merkle tree where each leaf is the User's commitment to plaintext encodings.

### Commitment to the TLS handshake data

This is the `User`'s commitment to miscellaneous public data of the TLS handshake, namely:
- server certificate chain
- signature over the `server ephemeral public key` made using `server certificate chain`
- client random
- server random


### Time

The time when the Notary signed the `Session Header`.

### Total bytes sent and received

The total amount of application data bytes which the `User` sent to and received from the server.

# Notarized session

The `Notary` signs the following artifacts known as a `Session Header`, thereby attesting to the authenticity of the plaintext from a TLS session. The `User` can then use the signed `Session Header` to prove data provenance to a third-party `Verifier`.

It's important to highlight that throughout the entire TLSNotary protocol, including this signing stage, the `Notary` does not gain knowledge of either the plaintext or the server with which the `User` communicated.

## Session Header

A `Session Header` consists of the following components:

### Server Ephemeral Public Key

In TLS, session keys are derived from a one-time per-TLS-session ephemeral public key. The server signs this key with its certificate and transmits both the key and the signature to the `User`.

Since the `Notary` remains unaware of the signature or the certificate, the server's identity is concealed. However, the `User` can disclose the server's identity to a `Verifier` by revealing the signature and the certificate.

### Plaintext Encodings

These are the [encodings](../mpc/encodings.md) employed by the Notary to encode the plaintext.

Again, note that the `Notary` does not gain knowledge of the actual plaintext. The `Notary` transmits these encodings to the `User` using [Oblivious Transfer](../mpc/oblivious_transfer.md).

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


## Session Data

<!-- // (can be seen in tlsn-core/src/session/data.rs) -->

- `handshake_data_decommitment` contains `HandshakeData` which the `User` committed to (with salt)
`HandshakeData` contains various TLS-specific details:
    - `server_cert_details` (server certificate chain)
    - `server_kx_details` (data used in ECDH key exchange)
    - `client_random` (client random from the `Client Hello` TLS message)
    - `server_random` (server random from the `Server Hello` TLS message)

- `tx_transcript` and `rx_transcript` contain all application level plaintext bytes which were transmitted to/received from the server

- `merkle_tree` is a Merkle tree the leaves of which are the `User`'s commitments to plaintext. The `User` may commit to multiple slices of plaintext and then selectively disclose to the `Verifier` only those slices which he wants to make public

- `commitments` contains the `User`'s commitments to plaintext, where each commitment structure is:
    - `merkle_tree_index` is the index in the `merkle_tree`
    - `commitment` is the actual commitment value e.g. a blake3 hash
    - `ranges` are byte ranges within `tx/rx_transcript` where the bytes committed to are located
    - `direction` is used to identify whether it is a commitment to tx or rx data
    - `salt` is a salt for the `commitment`




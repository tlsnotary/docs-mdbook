# Encryption, Decryption, and MAC Computation

This section explains how the `User` and `Notary` use MPC to encrypt data for the server, decrypt data received from the server, and compute the MAC for the ciphertext in MPC.

## Encryption

To encrypt the plaintext, both parties input their key shares as private inputs to the [MPC](/mpc/deap.md) protocol, along with some other public data. Additionally, the `User` inputs her plaintext as a private input.

Both parties see the resulting ciphertext and execute the [2PC MAC](../../mpc/mac.md) protocol to compute the MAC for the ciphertext.

The `User` then dispatches the ciphertext and the MAC to the server.

As explained in the [Commitment section](commitment.md), the `User` creates a commitment to the plaintext (her private input to MPC).

## Decryption

Once the `User` receives the ciphertext and its associated MAC from the server, the parties first authenticate the ciphertext by validating the MAC. They do this by running the [MPC](/mpc/mac.md) protocol to compute the authentic MAC for the ciphertext. They then verify if the authentic MAC matches the MAC received from the server.

Next, the parties decrypt the ciphertext by providing their key shares as private inputs to the [MPC](/mpc/deap.md) protocol, along with the ciphertext and some other public data.

The resulting plaintext is revealed ONLY to the `User`.

As discussed in the [Commitment section](/protocol/notarization/commitment.md), the `User` creates a commitment to the plaintext.

Please note, the actual low-level implementation details of `Decryption` are more nuanced than what we have described here. For more information, please consult [Low-level Decryption details](/mpc/encryption.md).

## Summary

This chapter illustrated how the `Notary` and `User` collaborate to encrypt and decrypt data. The `Notary` performs these tasks "blindly", without acquiring knowledge of the plaintext. In fact, the `Notary` even remains unaware of which `Server` the `User` is communicating with. Additionally, the `User` creates commitments to the plaintext and can use them later to prove the authenticity of the plaintext to a third party `Verifier`.

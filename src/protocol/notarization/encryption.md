# Encryption and Decryption (and MAC computation)

Here we explain how the `User` and the `Notary` use MPC to encrypt the data for the server and also how they decrypt the data received from the server. They also compute the MAC for the ciphertext in MPC.

## Encryption

In order to encrypt the plaintext, the parties input their key shares as private inputs to the [MPC](/mpc/deap.md) protocol (along with some other public data). Additionally, the `User` inputs her plaintext as a private input.

Both parties learn the resulting ciphertext and they proceed to run an [MPC](/mpc/mac.md) protocol to compute the MAC for the ciphertext.

The User sends the ciphertext with the MAC to the server.

As we explain in the [Commitment section](/protocol/notarization/commitment.md), the `User` creates a commitment to the plaintext (her private input to MPC).


## Decryption

After the `User` receives the ciphertext with the associated MAC from the server, the parties first authenticate the ciphertext by checking if MAC is valid. They do it by running an [MPC] (/mpc/mac.md) protocol to compute the authentic MAC for the ciphertext. Then they check if the authentic MAC matches the MAC received from the server.

The parties then decrypt the ciphertext by inputting their key shares as private inputs to the [MPC](/mpc/deap.md) protocol (along with the ciphertext and some other public data).

The resulting plaintext is revealed ONLY to the User.

As we explain in the [Commitment section](/protocol/notarization/commitment.md), the `User` creates a commitment to the plaintext. 

Note that the actual low-level details of implementation of `Decryption` are more nuanced than what we described here. Please consult the [Low-level Decryption details](/mpc/encryption.md) for more information.



To summarize:

We showed above how the Notary and User work together to encrypt and decrypt data. The Notary does it "blindly", without learning the plaintext. In fact, the Notary does not even know which server the User is communicating with.
Additionally, the User created commitments to the plaintext and will be able to later prove the plaintext authenticity to a third party.

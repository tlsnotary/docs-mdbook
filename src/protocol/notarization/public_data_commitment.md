# Commitment to public data

We describe an interactive protocol between the User `U` and the Notary `N`, whereby `U` can convert the authenticated AES ciphertext into a hash commitment to Garbled Circuits wire labels.

## Creating the new commitment

0. At the end of the TLSNotary session, both `U` and `N` know the authenticated AES `ciphertext`. 

1. `N` reveals his TLS session key shares to `U`.

2. `U` decrypts the `ciphertext` in the clear and learns the plaintext `p`.

3. `N` picks a `seed` and uses it as the source of randomness to generate (in the semi-honest model) a privacy-free garbled circuit whose functionality is to accept the plaintext input, encrypt it, and output the ciphertext. 

4. With `p` as her circuit input, `U` receives input wire labels `IWLs` via Oblivious Transfer and then evaluates the circuit on those `IWLs`. The result of the evaluation are output wire labels `OWLs` which `U` does not know the decoding for.

5. `U` sends two commitments: `commitment to IWLs` and `commitment to OWLs` to `N`.

6. `N` reveals the `seed` and `U` checks that the circuit (including its `IWLs` and `OWLs`) was generated correctly and, if successful, reveals her `OWLs`.

7. `N` verifies `commitment to OWLs` and then checks that decoded `OWLs` match the `ciphertext` (from Step 0) and, if successful, signs (`seed` + `commitment to IWLs`). 

> Now, (`seed` + `commitment to IWLs`) become `U`'s new commitment to `p`.

## Verifying the commitment

Verifier performs the following steps:

1. Receives the following from `U`: plaintext `p`, `signature` for (`seed` + `commitment to IWLs`), `seed`, `commitment to IWLs`.

2. (using a trusted `N`s pubkey) Verifies the `signature`.

3. Re-generates the `IWLs` from the `seed`.

4. Picks only those `IWLs` which correspond to `p` and checks that the commitment to those `IWLs` matches `commitment to IWLs`.

5. Accepts `p` as authentic.


## Dynamic commitment using a Merkle tree

In situations where `U` does not know in advance which subset of the public data she will be revealing later to the Verifier, `U` can commit to the Merkle tree of all her input wire labels (from Step 4 above). 
Later, `U` can reveal only those Merkle leaves which she wants to make public to the Verifier. 


# Server identity privacy

To maximize `Prover` privacy, the server identity is not revealed to the `Verifier` by default. 
The TLSNotary protocol mitigates the threat of a malicious `Verifier` attempting to infer the server identity from the messages they receive during MPC-TLS. 
The exact low-level details are outlined below.

## Handshake hash

During the MPC-TLS handshake, the `Verifier` learns the hash digest of all handshake messages
(see "Verify Data" in https://tls12.xargs.org/#client-handshake-finished/annotated). 
If the hashed message lacks sufficient randomness that is unknown to the `Verifier`, they could collect all TLS certificates in existence and attempt a dictionary attack on the digest.

## Sources of handshake randomness

The randomness in a handshake comes from `client random`, `server random`, and the `signature` (see "Signature" in https://tls12.xargs.org/#server-key-exchange/annotated). For optimization, both `client random` and `server random` are revealed to the `Verifier` during MPC-TLS. We argue that the `signature` contains sufficient randomness unknown to the `Verifier` to prevent the dictionary attack described above.

Note that the signed message **is known** to the `Verifier`. This message is computed as H(`client_random` + `server_random` + kx_params), where 
- H is a hash function, usually SHA256
- kx_params are ECDHE key exchange parameters known to the `Verifier`

## Signature unforgeability

Unforgeability is a key property of signature schemes that ensures that even if the attacker (the `Verifier` in this case) knows both the message the public key of the signer, it is computationally infeasible to forge a valid signature for that message.

>We follow the terminology from the signature forgery taxonomy here: https://crypto.stackexchange.com/questions/44188/what-do-the-signature-security-abbreviations-like-euf-cma-mean/44210#44210
> - `EF-CMA`: Existential Forgery under Chosen-Message Attack
> - `UF-KMA`: Universal Forgery under Known-Message Attack

All TLS signature schemes are EF-CMA-secure, but we argue that even the weaker UF-KMA security would suffice for our scenario where an attacker is given:
- an arbitrary message,
- a public key, and
- many arbitary messages and their signatures collected from previous server interactions.

This scenario fits precisely within the UF-KMA model. Since UF-KMA is a subset of EF-CMA, we conclude that our approach is secure.


#### A note on RSASSA-PKCS1-v1_5 message extraction

Under RSASSA-PKCS1-v1_5, the message can be extracted from the signature. However, this peculiarity has no impact on our goal, as the `Verifier` does not learn the signature in the first place.

#### A note on ECDSA public key recovery

Under ECDSA, the pubkey can be recovered from a message and its signature. Again, this peculiarity does not affect our goal, as the `Verifier` does not learn the signature in the first place.
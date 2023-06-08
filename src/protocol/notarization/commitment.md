# Commitment

At the end of the TLSNotary protocol, the User has the authenticated AES ciphertext which can be thought of as a commitment to the plaintext. This form of commitment is not amenable to use cases when the User wants to make part of the plaintext public while keeping another part private. Naively, the User's option is to prove the decryption of the ciphertext in zero-knowledge which is computationally expensive.

We describe two less computationally heavy approaches for converting the AES ciphertext commitments. 

The first approach is useful for commitments to the data which the User intends to make public. It is based on decrypting the ciphertext with Garbled Circuits and producing a hash commitment to the wire labels.

The second approach is useful for commitments to the private data which the User later intends to prove statements about in zero-knowledge. This approach produces a Poseidon hash over the private data. 
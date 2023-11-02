# MPC-TLS

During the MPC-TLS phase the `Prover` and the `Verifier` run an MPC protocol enabling the `Prover` to connect to, and exchange data with, a TLS-enabled `Server`. 


Listed below are some key points regarding this protocol:


- The `Verifier` only learns the *encrypted* application data of the TLS session.
- The `Prover` is not solely capable of constructing requests, nor can they forge responses from the `Server`.
- The protocol enables the `Prover` to prove the authenticity of the exchanged data to the `Verifier`. 


<!-- The MPC-TLS protocol consists of the following steps:

1. **Handshake**  
A TLS handshake is the first step in establishing a TLS connection between the `Prover`/`Verifier` and the `Server`. The result of this handshake is a *Pre Master Secret (PMS)*, a symmetrical key that will be used for further encrypted communication. The server has the full key; the `Prover` and the `Verifier` only have their share of this key.
2. **Encryption, Decryption, and MAC Computation**  
Next, the `Prover` and `Verifier` use MPC to encrypt, and decrypt, data sent to, and received from, the `Server`. They also compute a *Message Authentication Code (MAC)* 
for the data that ensures untampered communication. -->
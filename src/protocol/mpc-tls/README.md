# MPC-TLS

During the MPC-TLS Phase the `Prover` and the `Verifier` work together to generate an authenticated `Transcript` of a TLS session with a `Server`.

Listed below are some key points regarding this process:

 - The identity of the `Server` can be hidden from the `Verifier`, while the `Prover` is still capable of proving the `Server` identity later.
 - The `Verifier` only ever sees the *encrypted* application data of the TLS session.
 - The protocol guarantees that the `Prover` is not solely capable of constructing requests, nor can they forge responses from the `Server`.

# Commit Strategy
When the `Prover` generates authenticated commitments to the plaintext of the transcript, he can choose which portion(s) of the plaintext to commit to. This dictates the portion(s) that can be selectively disclosed later to the application-specific `Verifier`. This section discusses different commit strategies, as well as their associated costs.

## Strategy
Given a transcript plaintext of `N` bytes long, the `Prover` can choose from a variety of commit strategies. For example, he can perform one commit to the portion that corresponds to the response body. He can also perform `N` commits to every byte of the transcript. The details of various commit strategies are discussed in the table below.

| # | Strategy | Description | Selective Disclosure | Cost | Usage |
| - | -------- | ----------- | -------------------- | ---- | ----- |
| 1 | Commit to custom portion(s) | Only commit to the portion(s) that need to be selectively disclosed later | Cannot selectively disclose anything other than the committed portion(s) | Small artefact size if only a few portions committed | Suitable when only a single (or a few) selective disclosure pattern is needed |
| 2 | Commit to HTTP objects | Commit to portions that correspond to all common HTTP objects in both request and response, e.g. every header's key and value, every key and value in JSON response body | Flexible to selectively disclose different HTTP objects of transcript at different times | Larger artefact size than strategy #1 | Ideal for most use cases — the default strategy used in the repository's [example](https://github.com/tlsnotary/tlsn/blob/4d5102b6e141ecb84b8a835604be1d285ae6eaa5/crates/examples/attestation/prove.rs#L99) |
| 3 | Commit to each byte | One commit for each byte, resulting in `N` portions committed | Maximum flexibility as any portion of the transcript can be selectively disclosed at different times | Largest artefact size among all strategies | Suitable when needed to support selective disclosure on many arbitrary portions beyond common HTTP objects |

## Cost
These strategies mainly differ in the number of portions committed (`K`). As `K` increases, the major cost that increases is the size of the artefact generated (*artefact size* in the table above). The artefact generated, as well as the factor by which their associated size increases when `K` increases (*size scaling*) are detailed in the table below.

| # | Artefact | Description | Size Scaling | Explanation |
| - | -------- | ----------- | ------------ | ---------------------- |
| 1 | `Attestation` | Artifact signed by the `Notary` attesting to the authenticity of the plaintext from a TLS session | Constant | `Attestation` only contains data  that remains constant-sized regardless of `K`, e.g. the merkle root of the commitments |
| 2 | `Secret` | Artifact containing secret data that correspond to commitments in `Attestation` | Linear | `Secret` contains some data whose sizes scale linearly with `K`, e.g. a merkle tree whose number of leaves equals to `K` |

Using the default setting, every additional portion costs around 250 bytes of secret size increment. For more details, please visit this [Jupyter notebook](https://colab.research.google.com/drive/1o7IOwxZ9DuZLNsg6sQKp2y25kzgUPJhC?usp=sharing).
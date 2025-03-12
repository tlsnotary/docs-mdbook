# Rust Quick Start

This quick start demonstrates how to use TLSNotary with Rust code.

## Requirements

Before we start, make sure you have cloned the `tlsn` repository and have a recent version of Rust installed.

1. Clone the `tlsn` repository (defaults to the `main` branch, which points to the latest release):
    ```shell
    git clone https://github.com/tlsnotary/tlsn.git
    ```
2. If you don't have Rust installed yet, you can install it using [rustup](https://rustup.rs/). If your Rust version is outdated, update it with `rustup update stable`.

## Simple Interactive Verifier: Verifying Data from an API in Rust<a name="interactive"></a>

![](../diagrams/overview_prover_verifier.svg)

This example demonstrates how to use TLSNotary in a simple interactive session between a Prover and a Verifier. It involves the Verifier first verifying the MPC-TLS session and then confirming the correctness of the data.

Follow the instructions from:
<https://github.com/tlsnotary/tlsn/tree/main/crates/examples/interactive#readme>

## Simple Attestation Example: Verifying Data from an API in Rust with a Notary<a name="attestation"></a>

![](../diagrams/overview_notary.svg)

TLSNotary can also be used in a setup where MPC-TLS verification is delegated to a notary server. In this example, the notary attests to the data served to the prover. Next, the prover can share this attestation with a Verifier who can verify the data.

Follow the instructions from:
<https://github.com/tlsnotary/tlsn/tree/main/crates/examples/attestation#readme>

🍾 Great job! You have successfully used TLSNotary in Rust.

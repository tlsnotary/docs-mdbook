# Rust Quick Start

This Quick Start demonstrates the simplest possible use case for TLSNotary. A Prover notarizes data from a local test server with a local Notary.

## Requirements

Before we start, make sure you have cloned the `tlsn` repository and have a recent version of Rust installed.

###  Clone the TLSNotary Repository

Clone the `tlsn` repository (defaults to the `main` branch, which points to the latest release):

```shell
git clone https://github.com/tlsnotary/tlsn.git
```

Next open the `tlsn` folder in your favorite IDE.

### Install Rust

If you don't have Rust installed yet, you can install it using [rustup](https://rustup.rs/):

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

To configure your current shell, run:
```shell
source "$HOME/.cargo/env"
```

## Simple Interactive Verifier: Verifying Data from an API in Rust<a name="interactive"></a>

Follow the instructions from:
<https://github.com/tlsnotary/tlsn/tree/main/crates/examples/interactive#readme>

## Simple Attestation Example<a name="attestation"></a>

Follow the instructions from:
<https://github.com/tlsnotary/tlsn/tree/main/crates/examples/attestation#readme>


🍾 Great job! You have successfully used TLSNotary in Rust.

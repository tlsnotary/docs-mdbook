# TLSNotary mdBook Documentation

## Build

Install mdbook and mdbook-katex

```bash
cargo install mdbook --version 0.4.45
cargo install mdbook-katex --version 0.9.3
cargo install mdbook-linkcheck
```

Then build and serve

```bash
mdbook serve
```

## Diagrams

All diagrams are made with [draw.io](https://app.diagrams.net/). The diagram source files are stored in the `diagrams` folder.
The diagram sources can be converted to `png` with the `convert_all.sh` script in the diagrams folder.
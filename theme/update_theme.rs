#!/usr/bin/env cargo +nightly -Zscript

// This script fetches the 'index.hbs' file from the mdBook repository and filters the
// content to only present the 'ayu' theme.

//! ```cargo
//! [dependencies]
//! reqwest = { version = "0.11", features = ["blocking"] }
//! ```

use reqwest::blocking;
use std::fs::File;
use std::io::{self, Write};

const MDBOOK_VERSION: &str = "0.4.36";

fn main() -> io::Result<()> {
    let url = format!(
        "https://raw.githubusercontent.com/rust-lang/mdBook/v{MDBOOK_VERSION}/src/theme/index.hbs"
    );

    let response = blocking::get(&url)
        .expect("fetching template file")
        .text()
        .expect("getting text from template fetch");

    // filter unwanted themes: only keep ayu
    let filtered_content = response
        .lines()
        .filter(|line| {
            if line.contains("role=\"menuitem\"") {
                line.contains("id=\"ayu\"")
            } else {
                true
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    let mut file = File::create("index.hbs")?;
    file.write_all(filtered_content.as_bytes())?;

    Ok(())
}

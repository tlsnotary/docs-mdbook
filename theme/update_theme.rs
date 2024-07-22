#!/usr/bin/env cargo +nightly -Zscript
---
[dependencies]
reqwest = { version = "0.11", features = ["blocking"] }
---

// This script fetches the 'index.hbs' file from the mdBook repository and filters the
// content to only present the 'ayu' theme.

use reqwest::blocking;
use std::fs::File;
use std::io::{self, Write};

const MDBOOK_VERSION: &str = "0.4.40";

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

    // Add Matomo tracking script before </body>
    let tracking_script = r#"      <script>
            var _paq = window._paq = window._paq || [];
            _paq.push(['trackPageView']);
            _paq.push(['enableLinkTracking']);
            (function() {
                var u="https://psedev.matomo.cloud/";
                _paq.push(['setTrackerUrl', u+'matomo.php']);
                _paq.push(['setSiteId', '16']);
                var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                g.async=true; g.src='//cdn.matomo.cloud/psedev.matomo.cloud/matomo.js'; s.parentNode.insertBefore(g,s);
            })();
        </script>
    </body>"#;

    let final_content = filtered_content.replace("</body>", tracking_script);

    let mut file = File::create("index.hbs")?;
    file.write_all(final_content.as_bytes())?;

    Ok(())
}

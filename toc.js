// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded affix "><a href="intro.html">Introduction</a></li><li class="chapter-item expanded affix "><a href="motivation.html">Motivation</a></li><li class="chapter-item expanded affix "><a href="faq.html">FAQ</a></li><li class="chapter-item expanded affix "><li class="part-title">Getting Started</li><li class="chapter-item expanded "><a href="quick_start/index.html"><strong aria-hidden="true">1.</strong> Quick Start</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="quick_start/rust.html"><strong aria-hidden="true">1.1.</strong> Rust</a></li><li class="chapter-item expanded "><a href="quick_start/tlsn-js.html"><strong aria-hidden="true">1.2.</strong> Browser</a></li><li class="chapter-item expanded "><a href="quick_start/browser_extension.html"><strong aria-hidden="true">1.3.</strong> Browser Extension</a></li></ol></li><li class="chapter-item expanded "><a href="developers/notary_server.html"><strong aria-hidden="true">2.</strong> Run a Notary Server</a></li><li class="chapter-item expanded affix "><li class="part-title">Protocol</li><li class="chapter-item expanded "><a href="protocol/mpc-tls/index.html"><strong aria-hidden="true">3.</strong> MPC-TLS</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="protocol/mpc-tls/handshake.html"><strong aria-hidden="true">3.1.</strong> Handshake</a></li><li class="chapter-item expanded "><a href="protocol/mpc-tls/encryption.html"><strong aria-hidden="true">3.2.</strong> Encryption and Decryption</a></li></ol></li><li class="chapter-item expanded "><a href="protocol/notarization.html"><strong aria-hidden="true">4.</strong> Notarization</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="protocol/commit_strategy.html"><strong aria-hidden="true">4.1.</strong> Commit Strategy</a></li></ol></li><li class="chapter-item expanded "><a href="protocol/verification.html"><strong aria-hidden="true">5.</strong> Verification</a></li><li class="chapter-item expanded "><a href="protocol/server_identity_privacy.html"><strong aria-hidden="true">6.</strong> Server Identity Privacy</a></li><li class="chapter-item expanded "><div><strong aria-hidden="true">7.</strong> Selective Disclosure</div></li><li class="chapter-item expanded affix "><li class="part-title">MPC</li><li class="chapter-item expanded "><a href="mpc/key_exchange.html"><strong aria-hidden="true">8.</strong> Key Exchange</a></li><li class="chapter-item expanded "><a href="mpc/ff-arithmetic.html"><strong aria-hidden="true">9.</strong> Finite-Field Arithmetic</a></li><li class="chapter-item expanded "><a href="mpc/deap.html"><strong aria-hidden="true">10.</strong> Dual Execution with Asymmetric Privacy</a></li><li class="chapter-item expanded "><a href="mpc/encryption.html"><strong aria-hidden="true">11.</strong> Encryption</a></li><li class="chapter-item expanded "><a href="mpc/mac.html"><strong aria-hidden="true">12.</strong> MAC</a></li><li class="chapter-item expanded "><a href="mpc/commitments.html"><strong aria-hidden="true">13.</strong> Commitments</a></li><li class="chapter-item expanded affix "><li class="part-title">Browser Extension</li><li class="chapter-item expanded "><a href="extension/extension.html"><strong aria-hidden="true">14.</strong> Extension</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="extension/plugins.html"><strong aria-hidden="true">14.1.</strong> Plugins</a></li><li class="chapter-item expanded "><a href="extension/provider.html"><strong aria-hidden="true">14.2.</strong> Provider API</a></li></ol></li><li class="chapter-item expanded "><a href="glossary.html">Glossary</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);

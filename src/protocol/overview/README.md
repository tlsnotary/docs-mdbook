# Overview

<div>
    <style>
        .zoom-without-container {
           transition: transform .2s; /* Animation */
           margin: 0 auto;
         }
         .zoom-without-container img{
         	width:100%;
         	height:auto;	
         }
         .zoom-without-container:hover {
           transform: scale(2);
         }
    </style>
    <div class="zoom-without-container">
        <img src="https://raw.githubusercontent.com/tlsnotary/docs-assets/main/diagrams/overview.png" alt="zoom">
    </div>
</div>

The TLSNotary protocol can be decomposed into three distinct phases:

1. [Request Phase](./request.md)
2. Notarization Phase
3. Selective Disclosure Phase
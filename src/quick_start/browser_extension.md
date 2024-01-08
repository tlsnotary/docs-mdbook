# TLSNotary Browser Extension <a name="browser"></a>

In this Quick Start we will prove ownership of a Twitter account with TLSNotary's browser extension.

## Run Notary Server

1. Edit the notary server config [file](./notary/config/config.yaml) to turn off TLS so that the browser extension can connect to the local notary server without requiring extra steps to accept self-signed certificates in the browser.
   ```yaml
   tls-signature:
      enabled: false
   ```
2. Run the notary server:
   ```shell
   cd notary-server
   cargo run --release
   ```

The notary server will now be running in the background waiting for connections.

## Install Browser Extension (Chrome/Brave)

1. Download the browser extension from
<https://github.com/tlsnotary/tlsn-extension/releases/download/0.0.1/tlsn-extension-0.0.1.zip>

2. Unzip  
   ⚠️ This is a flat zip file, so be careful if you unzip from the command line, this zip file contains many file at the top level
3. Open **Manage Extensions**: <chrome://extensions/>
4. Enable `Developer mode`
5. Click the **Load unpacked** button
6. Select the unzipped folder

![](images/extension_install.png)

(Optional:) Pin the extension, so that it is easier to find in the next steps:

![](images/extension_pin.png)

## Websocket Proxy

Since a web browser doesn't have the ability to make TCP connection, we need to use a websocket proxy server. You can either run one yourself, or use a TLSNotary hosted proxy.

### Local Proxy

To run your own websockify proxy locally, run:
```
git clone https://github.com/novnc/websockify && cd websockify
./docker/build.sh
docker run -it --rm -p 55688:80 novnc/websockify 80 api.twitter.com:443
```
Note the `api.twitter.com:443` argument on the last line.

### Hosted proxy

Or, you can simply use remote proxy at `ws://notary.efprivacyscaling.org:55688`

1. Open the extension
2. Click "Option"
3. Update proxy URL and click "Save"

<img width="478"  src="images/extension_proxy.png">

## Notarize Twitter Account Access

* Open Twitter <https://twitter.com> and login if you haven't yet.
* open the extension, you should see requests being recorded:  
<img width="477"  src="images/extension_requests.png">
* If you click "Notarize" here, the extension will automatically notarize the correct request to prove your twitter ID. **However, we are going to do it manually**
* Click on "Requests", and then search for the text "setting" in search box:  
<img width="479"  src="images/extension_request.png">
* Select the request, and then click on **Notarize**:  
<img width="477"  src="images/extension_headers.png">
* First, select any headers that you would like to reveal.  
<img width="479"  src="images/extension_headers_reveal.png">
* Second, highlight the text that you want to make public to hide everything else.
<img width="479"  src="images/extension_text_reveal.png">
* Click **Notarize**, you should see your notarization being processed:
<img width="477"  src="images/extension_process.png">

You can open the offscreen console and observe the browser extension logs by going to <chrome://extensions> -> TLSN Extension -> Details -> offscreen.html

## Verify

When the notarization is ready, you can click **View Proof**.

If you did close the UI, you can find the proof by clicking **History** and **View Proof**.

<img width="477" src="images/extension_history.png">

You also have the option to download the proof. You can view this proof later by using the **Verify** button or via <https://tlsnotary.github.io/proof_viz/>.

## Troubleshooting

* Requests(0): no requests in the Browser extension => restart the TLSN browser extension in <chrome://extensions/> and reload the Twitter page.
* Is the notary server still running? It should, check the console log.

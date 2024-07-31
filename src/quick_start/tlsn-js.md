# TLSNotary in React/Typescript with `tlsn-js`<a name="browser"></a>

In this Quick Start you will learn how to use TLSNotary in React/Typescript with [`tlsn-js`](https://github.com/tlsnotary/tlsn-js) NPM module in the browser.

This Quick Start uses the react/typescript [demo app in `tlsn-js`](https://github.com/tlsnotary/tlsn-js/tree/main/demo/react-ts-webpack). The directory contains a webpack configuration file that allows you to quickly bootstrap a webpack app using `tlsn-js`.

## `tlsn-js` in a React/Typescript app

In this demo, we will request JSON data from the Star Wars API at <https://swapi.dev>. We will use `tlsn-js` to notarize the TLS request with TLSNotary and store the result in a *proof*. Then, we will use `tlsn-js` again to verify this *proof*.

> **_NOTE:_** ℹ️ This demo uses TLSNotary to notarize **public** data to simplify the Quick Start for everyone. For real-world applications, TLSNotary is particularly valuable for notarizing private and sensitive data.



1. Clone the repository
    ```sh
    git clone https://github.com/tlsnotary/tlsn-js    
    ```
2. Navigate to the demo directory:
    ```sh
    cd tlsn-js/demo/react-ts-webpack
    ```
3. Checkout the version of this Quick Start:
    ```sh
    git checkout v0.1.0-alpha.5.3
    ```
4. If you want to use a local TLSNotary server: [Run a local notary server and websocket proxy](#local), otherwise:
   1. Open `app.tsx` in your favorite editor.
   2. Replace `notaryUrl: 'http://localhost:7047',` with:
         ```ts
            notaryUrl: 'https://notary.pse.dev/v0.1.0-alpha.6',
         ```
      This makes this webpage use the [PSE](https://pse.dev) notary server to notarize the API request. Feel free to use different or [local notary](#local); a local server will be faster because it removes the bandwidth constraints between the user and the notary.
   3. Replace `websocketProxyUrl: 'ws://localhost:55688',` with:
        ```ts
            websocketProxyUrl: 'wss://notary.pse.dev/proxy?token=swapi.dev',
        ```
      Because a web browser doesn't have the ability to make TCP connection, we need to use a websocket proxy server. This uses a proxy hosted by [PSE](https://pse.dev). Feel free to use different or [local notary](#local) proxy.
   4. In `package.json`: check the version number:
        ```json
            "tlsn-js": "v0.1.0-alpha.6.0"
        ```
5. Install dependencies
    ```sh
    npm i
    ```
6. Start Webpack Dev Server:
    ```sh
    npm run dev
    ```
7. Open `http://localhost:8080` in your browser
8. Click the **Start demo** button
9. Open **Developer Tools** and monitor the console logs


## Run a local notary server and websocket proxy <a name="local"></a> (Optional)

The instructions above, use the [PSE](https://pse.dev) hosted notary server and websocket proxy. This is easier for this Quick Start because it requires less setup. If you develop your own applications with `tlsn-js`, development will be easier with locally hosted services. This section explains how.

### Websocket Proxy <a name="proxy"></a>

Since a web browser doesn't have the ability to make TCP connection, we need to use a websocket proxy server.

Run your own websockify proxy **locally**:
```sh
git clone https://github.com/novnc/websockify && cd websockify
./docker/build.sh
docker run -it --rm -p 55688:80 novnc/websockify 80 swapi.dev:443
```

Note the `swapi.dev:443` argument on the last line, this is the server we will use in this quick start.

### Run a Local Notary Server <a name="local-notary"></a>

For this demo, we also need to run a local notary server.

1. Clone the TLSNotary repository  (defaults to the `main` branch, which points to the latest release):
   ```sh
   git clone https://github.com/tlsnotary/tlsn.git
   ```
2. Edit the notary server config file (`notary/server/config/config.yaml`) to turn off TLS so that self-signed certificates can be avoided (⚠️ this is only for local development purposes — TLS must be used in production).
   ```yaml
   tls:
      enabled: false
   ```
3. Run the notary server:
   ```sh
   cd notary/server
   cargo run --release
   ```

The notary server will now be running in the background waiting for connections.

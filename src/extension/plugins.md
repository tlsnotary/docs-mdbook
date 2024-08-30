# Browser Extension Plugins

The **TLSN Extension** has a plugin system that allows you to safely extend its functionality. The plugin system is based on [Extism](https://extism.org/docs/concepts/plug-in-system), which enables you to write plugins in the programming language of your choice. This page focuses on plugins written in TypeScript.

## What Can You Do with Plugins?

Plugins can add new custom features to the extension by using built-in host functions, such as:

- Requesting private information from the browser, such as cookies and headers of one or more hostnames.
- Submitting a new notarization request using the [prove](https://github.com/tlsnotary/tlsn-js/blob/main/src/tlsn.ts#L48-L89) method in [tlsn-js](https://www.npmjs.com/package/tlsn-js).
- Redirecting a browsing window.

New features and capabilities will be added based on feedback from developers. Please reach out to us on [Discord](https://discord.gg/9XwESXtcN7).

## Templates and Examples

You can find a boilerplate template at [tlsn-plugin-boilerplate](https://github.com/tlsnotary/tlsn-plugin-boilerplate), which is a great starting point. This repository explains how to compile and test Typescript plugins.

The [examples folder](https://github.com/tlsnotary/tlsn-plugin-boilerplate/tree/main/examples) contains more examples of TLSNotary plugins.

## Configuration JSON

A plugin must include a configuration JSON file that describes its behavior and permissions.

<!-- https://github.com/tlsnotary/tlsn-extension/blob/p2p/src/utils/misc.ts#L315-L326 -->
```ts
export type PluginConfig = {
  title: string;           // The name of the plugin
  description: string;     // A description of the plugin's purpose
  icon?: string;           // A base64-encoded image string representing the plugin's icon (optional)
  steps?: StepConfig[];    // An array describing the UI steps and behavior (see Step UI below) (optional)
  hostFunctions?: string[];// Host functions that the plugin will have access to
  cookies?: string[];      // Cookies the plugin will have access to, cached by the extension from specified hosts (optional)
  headers?: string[];      // Headers the plugin will have access to, cached by the extension from specified hosts (optional)
  requests: { method: string; url: string }[]; // List of requests that the plugin is allowed to make
  notaryUrls?: string[];   // List of notary services that the plugin is allowed to use (optional)
  proxyUrls?: string[];    // List of websocket proxies that the plugin is allowed to use (optional)
};
```

## Step UI

The plugin system allows customization of the UI and the functionality of the side panel.

<img src="images/steps_ui.png" height="640">

### Step Configuration

The steps are declared in the JSON configuration:

```ts
type StepConfig = {
  title: string;         // Text for the step's title
  description?: string;  // OPTIONAL: Text for the step's description
  cta: string;           // Text for the step's call-to-action button
  action: string;        // The function name that this step will execute
  prover?: boolean;      // Boolean indicating if this step outputs a notarization
}
```

You need to implement the functionality of the steps in `src/index.ts`. The function names must match the corresponding step names in the JSON configuration.

## Host Functions

<!-- https://github.com/tlsnotary/tlsn-extension/blob/fe56de0b6cb4e235cabb0f8b2216853de2adb47f/src/utils/plugins.tsx#L5 -->
[Host functions](https://extism.org/docs/concepts/host-functions) are specific behaviors provided by the extension that the plugin can call. Host function usage may vary depending on the language used to write the plugin.

### `redirect`

Redirects the current tab to a different URL.

Example in JavaScript:
```js
const { redirect } = Host.getFunctions();
const mem = Memory.fromString('https://x.com');
redirect(mem.offset);
```

### `notarize`

Notarizes a request using the [prove](https://github.com/tlsnotary/tlsn-js/blob/main/src/tlsn.ts#L48-L89) method in [tlsn-js](https://www.npmjs.com/package/tlsn-js).

Example in JavaScript:
```js
const { notarize } = Host.getFunctions();
const mem = Memory.fromString(JSON.stringify({
  url: "https://...",
  method: "GET",
  headers: {
    "authorization": "Bearer xxx",
    "cookie": "lang=en; auth_token=xxx",
  },
  secretHeaders: [
    "authorization: Bearer xxx",
    "cookie: lang=en; auth_token=xxx",
  ],
  getSecretBody: "parseResponse" // See redaction example below
}));
const idOffset = notarize(mem.offset);
const id = Memory.find(idOffset).readString();
Host.outputString(JSON.stringify(id)); // Outputs the notarization ID
```

#### Redaction

If the `getSecretResponse` field of the `notarize` host function call is set, the corresponding method will be called to parse the response of the request. Make sure to also export this function in the `main` module declaration in `index.d.ts`.

```ts
function parseResponse() {
  const bodyString = Host.inputString();
  const params = JSON.parse(bodyString);
  const revealed = `"screen_name":"${params.screen_name}"`;
  const selectionStart = bodyString.indexOf(revealed);
  const selectionEnd = selectionStart + revealed.length;
  const secretResps = [
    bodyString.substring(0, selectionStart),
    bodyString.substring(selectionEnd, bodyString.length),
  ];
  Host.outputString(JSON.stringify(secretResps));
}
```
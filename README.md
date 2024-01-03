[![Gitter](https://badges.gitter.im/rebol3/community.svg)](https://app.gitter.im/#/room/#Rebol3:gitter.im)

# Rebol/WebDriver

WebDriver client for the [Rebol](https://github.com/Oldes/Rebol3) programming language.

Currently only `chrome` scheme is implemented which is supposed to be working
with Chromium, Chrome and other Blink-based browsers.

The browser must be started with `remote-debugging` enabled.

For example on macOS start a Brave browser from Terminal using command:

```terminal
/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser --remote-debugging-port=9222
```

Available methods are documented here: https://chromedevtools.github.io/devtools-protocol/

# Usage example

```rebol
import %websocket.reb           ;; The scheme depends on WebSocket module (which is not by default available yet)
import %webdriver.reb           ;; Importing the module from the source file direcly

system/options/quiet: false     ;; Modifies scripts output visibility
system/options/log/ws: 0        ;; No WebSocket traces
system/options/log/http: 0      ;; No HTTP traces

browser: open chrome://         ;; Initialize Chrome's WebDriver scheme (defaults to localhost:9222)

probe write browser [           ;; Sends multiple commands to be evaluated by the WebDriver scheme
	http://www.rebol.com        ;; Opens a page in the browser.
	Network.enable              ;; Enables network tracking, network events will now be delivered to the client.
	Page.enable                 ;; Enables page domain notifications.
	0:0:2                       ;; Waits 2 seconds while processing incomming events.
	DOM.getDocument [depth: -1] ;; Gets the root DOM node and the entire subtree (-1)
]

```

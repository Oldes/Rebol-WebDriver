[![Gitter](https://badges.gitter.im/rebol3/community.svg)](https://app.gitter.im/#/room/#Rebol3:gitter.im)

# Rebol/WebDriver

WebDriver client for the [Rebol](https://github.com/Oldes/Rebol3) programming language.

Currently, only the _Chrome_ scheme is implemented, designed to work with Chrome, Brave, Edge, and other Chromium-based browsers.

The browser must be started with `remote-debugging` enabled.

For example on macOS start a Brave browser from Terminal using command:

```terminal
/Applications/Brave\ Browser.app/Contents/MacOS/Brave\ Browser --remote-debugging-port=9222
```

Available methods are documented here: https://chromedevtools.github.io/devtools-protocol/

# Simple usage example

```rebol
import %websocket.reb           ;; The scheme depends on WebSocket module (which may not be available yet by default)
import %webdriver.reb           ;; Importing the module from the source file direcly

system/options/quiet:    off    ;; Modifies script's output visibility
system/options/log/ws:   0      ;; No WebSocket traces
system/options/log/http: 0      ;; No HTTP traces

browser: open chrome://         ;; Initialize Chrome's WebDriver scheme (defaults to localhost:9222)

write browser [                 ;; Sends multiple commands to be evaluated by the WebDriver scheme
    Network.enable              ;; Enable network tracking to capture network events.
    http://www.rebol.com        ;; Opens the specified webpage and waits for it to finish loading.
    0:0:1                       ;; (Optional) Waits for 1 second to process potential incoming events.
                                ;; This may help with dynamically updated pages.
    DOM.getDocument [depth: -1] ;; Retrieves the root DOM node along with the entire subtree (depth -1).
]

print pick browser 'DOM.getDocument ;; Prints the resolved DOM structure

close browser ;; Closes the session gracefully (similar to closing a page in the browser).
```

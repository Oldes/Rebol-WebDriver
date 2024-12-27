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

;- Printing the current webpage to PDF
tmp: write browser 'Page.printToPDF
write %page.pdf debase tmp/result/data 64 ;; Save the PDF data to a file (encoded in base64)

;- Navigating to another webpage within the session
write browser https://www.theguardian.com/news/series/ten-best-photographs-of-the-day
;; Content of this page is dynamically updated, so wait for it...
write browser 0:0:5

;; Received events are stored in the session and may be processed.
;; For example, to resolve all loaded JPEG images on the page...
foreach [n m] take/all browser/extra/events [
    if all [
        n == "Network.responseReceived"       ;; Look for network responses
        m/type == "Image"                     ;; Specifically, images
        m/response/status == 200              ;; Ensure the request succeeded
        m/response/mimeType == "image/avif"   ;; Filter for AVIF images
    ][
        probe m/response/url
        url: decode-url m/response/url        ;; Decode the image URL

        local-file: rejoin [
            %img_                             ;; Prefix for the file name
            checksum to binary! url/path 'md5 ;; Generate a checksum for the image URL
            #"_" url/target                   ;; Append the target filename
        ]

        ;; Check if the image is not already downloaded.
        if exists? local-file [
            print ["File already downloaded:" as-yellow local-file]
            continue
        ]

        ;; Request the image body.
        tmp: write browser compose/deep [Network.getResponseBody [requestId: (m/requestId)]]

        ;; Decode the image data (base64 if necessary).
        bin: tmp/result/body
        if tmp/result/base64Encoded [bin: debase bin 64]

        ;; Save the image to disk.
        probe write local-file bin
    ]
]

;- Closing the session gracefully
close browser ;; Close the session (similar to closing a page in the browser).
```
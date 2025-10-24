[![rebol-webdriver](https://github.com/user-attachments/assets/06e88a9a-f001-4361-9da9-32774fe05e0b)](https://github.com/Oldes/Rebol-WebDriver)


[![Gitter](https://badges.gitter.im/rebol3/community.svg)](https://app.gitter.im/#/room/#Rebol3:gitter.im)
[![Zulip](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://rebol.zulipchat.com/)

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
;; Content of this page is dynamically updated, so wait for it.
write browser 0:0:1

;; Simulate multiple mouse wheel events to scroll the webpage
loop 10 [
    write browser [
        Input.dispatchMouseEvent [type: "mouseWheel" x: 100 y: 100 deltaX: 0 deltaY: 800]
        0:0:1
    ]
]

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

Note: The above code demonstrates how the WebDriver module can be used to interact with webpages,
including downloading images dynamically. However, for simpler use cases (e.g., static webpages),
you can use a more straightforward and faster approach without the WebDriver module:

```rebol
import html-entities

html: read https://www.theguardian.com/news/series/ten-best-photographs-of-the-day

;- Parse the HTML to extract image URLs and download them
parse html [any[
    thru {<picture data-size="jumbo"}                ;; Locate the relevant section for large images
    thru {<source srcSet="} copy url to dbl-quote    ;; Extract the image URL
    (
        image-url: as url! decode 'html-entities url ;; Decode HTML entities in the URL
        url: decode-url image-url                    ;; Decode the image URL for further processing

        local-file: rejoin [
            %img_                                    ;; Prefix for the file name
            checksum to binary! url/path 'md5        ;; Generate a checksum for the image URL
            #"_" url/target                          ;; Append the target filename
        ]

        ;; Check if the image is not already downloaded.
        either exists? local-file [
            print ["File already downloaded:" as-yellow local-file]
        ][
            ;; Download and save the image
            try/with [
                write local-file read image-url
                print ["New image downloaded:" as-green local-file]
            ] :print
        ]
    )
] to end]
```

# Other useful examples
## Get all links from a given web page
```rebol
;; Initialize the browser scheme...
browser: open chrome://
res: write browser [
    https://www.rebol.com  ;; Open some web page.
    DOM.getDocument        ;; Get document's root node (not the full one!).
]
;; Check session results
try/with [
    session:  res/1/result ;; Not used.
    document: res/2/result ;; To get nodeId of the document root.
][
    ;; Quit early in case of insufficient info.
    print "Failed to initialize a session."
    quit
]
;; Query all nodes of type A (links)
res: write browser compose/deep [
    DOM.querySelectorAll [
        nodeId: (document/root/nodeId)
        selector: "a"
    ]
]
;; If any nodes are found, query the outer HTML of each.
if all [
    map? res
    block? nodes: res/result/nodeIDs
][ 
    links: copy []
    foreach node nodes [
        res: write browser compose/deep [DOM.getOuterHTML [nodeId: (node)]]
        try [append links res/result/outerHTML]
        
    ]
    ;; Print results.
    print ["Found" length? nodes "link (A) nodes"]
    foreach link links [ print link ]
]
;; Close page in the browser.
write browser [Page.close]
;; Close the session.
close browser
```
<img width="913" height="1557" alt="image" src="https://github.com/user-attachments/assets/8f99f502-e41d-4a81-ae09-77aaee6309c5" />


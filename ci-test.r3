Rebol [title: "WebDriver scheme test"]

import %websocket.reb
import %webdriver.reb

system/options/quiet: false   ;; Modifies scripts output verbosity
system/options/log/ws: 0      ;; No WebSocket traces
system/options/log/http: 0    ;; No HTTP traces

browser: open chrome://       ;; Initialize Chrome's WebDriver scheme (defaults to localhost:9222)

probe write browser [         ;; Sends multiple commands to be evaluated by the WebDriver scheme
	http://www.rebol.com        ;; Opens a page in the browser.
	Network.enable              ;; Enables network tracking, network events will now be delivered to the client.
	Page.enable                 ;; Enables page domain notifications.
	0:0:2                       ;; Waits 2 seconds while processing incomming events.
	DOM.getDocument [depth: -1] ;; Gets the root DOM node and the entire subtree (-1)
]
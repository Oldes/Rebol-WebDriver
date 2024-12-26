Rebol [title: "WebDriver scheme test"]

import %websocket.reb
import %webdriver.reb

system/options/quiet: false     ;; Modifies script's output verbosity
system/options/log/ws:   2      ;; Some WebSocket traces
system/options/log/http: 0      ;; No HTTP traces

browser: open chrome://         ;; Initialize Chrome's WebDriver scheme (defaults to localhost:9222)

;- Send multiple commands to be evaluated by the WebDriver scheme                                    
write browser [
	Network.enable              ;; Enables network tracking, network events will be delivered to the client.
	http://www.rebol.com        ;; Opens a page in the browser (waits for Page.frameStoppedLoading event).
	0:0:1                       ;; Waits 1 second while processing possible incomming events.
	                            ;; The wait mentioned above is usually unnecessary!
	                            ;; But some pages modify their content dynamically.
	DOM.getDocument [depth: -1] ;; Gets the root DOM node and the entire subtree (-1)
]

print-horizontal-line
dom-result: pick browser 'DOM.getDocument ;; resolved DOM
?? dom-result

print-horizontal-line 
close browser ;; Closes the session gracefully (similar to closing a page in the browser).

print-horizontal-line
print "TEST DONE"
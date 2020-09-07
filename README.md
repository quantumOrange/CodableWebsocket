#  Codable Websocket

A Combine Publisher and Subscriber that wraps a URLSessionWebSocketTask and makes it easy to send and receive any codable type over a websocket.

**Combine, SwiftUI, Websocket**

## Installation

It's just one file, CodableWebSocket.swift, so you can just drop it into your project.

##  Usage
Create a socket with a URL
```swift
let socket = CodableWebSocket<MyCodableType>(url:URL(string:"ws://echo.websocket.org")!)
```
You can send values to the websocket like this:

``` swift
 let value = MyCodableType()
    
    socket
        .receive(value)
```

And receive values fromt the server like this:

``` swift
let cancelable  = socket
                    .sink(receiveCompletion:
                            { completion in
                                switch completion
                                {
                                case .finished:
                                    break
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            },
                            receiveValue:
                            { value in
                                print("Receved:\(value)")
                            }
                        )
```



## Example

A simple example that conncets ws://echo.websocket.org which echos back whatever is sent. Whenever we hit send we send a **Thing** to the server, and we display whatever is sent back (which is just the **Thing** we sent).


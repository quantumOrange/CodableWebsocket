#  Codable Websocket

A Combine Publisher and Subscriber that wraps a URLSessionWebSocketTask and makes it easy to send and receive any codable type over a websocket.

**Combine, SwiftUI, Websocket**

##  Usage
You can create a socket with a URL with any type that conforms to the Codable protocol:
```swift
let socket = CodableWebSocket<MyCodableType>(url:URL(string:"ws://echo.websocket.org")!)
```
You can send values to the websocket like this:

``` swift
 let value = MyCodableType()
    
    socket
        .receive(.codable(value))
```

And receive values fromt the server like this:

``` swift
let cancelable  = socket
                    .codable
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
                                // do something with the value here
                                print("Receved:\(value)")
                            }
                        )
```

## Example

The example app is a simple demo that conects to ws://echo.websocket.org. This websocket just echos back whatever is sent. Whenever the user  hits the send button we send a **Thing** to the server. Whatever is sent back (which will be just the **Thing** we sent) we display on the screen.


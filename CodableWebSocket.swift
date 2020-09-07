//
//  WebSocket.swift
//  WebSocketDemo
//
//  Created by David Crooks on 07/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation
import Combine

final class CodableWebSocket<T:Codable>:Publisher,Subscriber {
  
    typealias Output = T
    typealias Input =  T
    typealias Failure = Error
    let webSocketTask:URLSessionWebSocketTask
    var combineIdentifier: CombineIdentifier = CombineIdentifier()
    
    init(url:URL)
    {
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with:url)
        webSocketTask.resume()
    }
    
    // MARK: Publisher
    
    func receive<S>(subscriber: S) where S : Subscriber, CodableWebSocket.Failure == S.Failure, CodableWebSocket.Output == S.Input {
        let subscription = WebsocketRecieveSubscription(subscriber: subscriber, socket:webSocketTask)
        subscriber.receive(subscription: subscription)
    }
    
   
    // MARK: Subscriber
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: T) -> Subscribers.Demand {
        
       
        if let data = try? JSONEncoder().encode(input) {
            let message = URLSessionWebSocketTask.Message.data(data)
            webSocketTask.send(message, completionHandler: {
                error in
                if let error = error {
                    Swift.print("\(error)")
                }
            })
        }

        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Error>) {
            Swift.print("Completion")
    }
    
}

final class WebsocketRecieveSubscription<SubscriberType: Subscriber, T: Codable>: Subscription where SubscriberType.Input == T,SubscriberType.Failure == Error {
    private var subscriber: SubscriberType?

    let webSocketTask:URLSessionWebSocketTask

    init(subscriber: SubscriberType, socket:URLSessionWebSocketTask) {
        self.subscriber = subscriber
        webSocketTask = socket
        receive()
    }

    func request(_ demand: Subscribers.Demand) {
        // Nothing to do here
    }

    func cancel() {
        Swift.print("Cancel!")
        subscriber = nil
    }

     func receive()
       {
        webSocketTask.receive
           {[weak self]result in
               switch result
               {
               case .failure(let error):
                let completion = Subscribers.Completion<Error>.failure(error)
                self?.subscriber?.receive(completion:completion)
                   
               case .success(let message):
                   switch message
                   {
                   case .string(_):
                        Swift.print("Websocket received message:\(message)")
                   case .data(let data):
                        if  let thing = try? JSONDecoder().decode(T.self, from: data)
                        {
                            _ = self?.subscriber?.receive(thing)
                        }
                   @unknown default:
                        break
                   }

                   self?.receive()
               }
           }
       }
}

//
//  WebSocket.swift
//  WebSocketDemo
//
//  Created by David Crooks on 07/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation
import Combine

enum SocketData<T:Codable> {
    case message(String)
    case codable(T)
    case uncodable(Data)
}

final class CodableWebSocket<T:Codable>:Publisher,Subscriber {
  
    typealias Output = Result<SocketData<T>,Error>
    typealias Input =  SocketData<T>
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

    func receive(_ input: SocketData<T>) -> Subscribers.Demand {
        let message:URLSessionWebSocketTask.Message
        
        switch input {
        
        case .message(let string):
            message = URLSessionWebSocketTask.Message.string(string)
        case .codable(let codable):
            if let data = try? JSONEncoder().encode(codable) {
                message = URLSessionWebSocketTask.Message.data(data)
            }
            else {
                fatalError()
            }
        case .uncodable(let data):
            message = URLSessionWebSocketTask.Message.data(data)
        }
    
        webSocketTask.send(message, completionHandler: {
            error in
            if let error = error {
                Swift.print("ERROR on send \(error)")
            }
        })
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Error>) {
            Swift.print("Completion")
    }
    
}

extension CodableWebSocket {
    func codable()-> AnyPublisher<T, CodableWebSocket<T>.Failure> {
        return compactMap{ result -> T? in
            guard case  Result<SocketData<T>,Error>.success(let socketdata) = result,
                case SocketData.codable(let codable) = socketdata
            else { return nil }
            return codable
        }.eraseToAnyPublisher()
    }
}

final class WebsocketRecieveSubscription<SubscriberType: Subscriber, T: Codable>: Subscription where SubscriberType.Input == Result<SocketData<T>,Error>,SubscriberType.Failure == Error {
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
        webSocketTask
            .receive
           {[weak self] result in
            let newResult:Result<SocketData<T>,Error> =  result.map { message in
                
                                                                        switch message
                                                                        {
                                                                        case .string(let str):
                                                                            return SocketData<T>.message(str)
                                                                        case .data(let data):
                                                                            if  let thing = try? JSONDecoder().decode(T.self, from: data)
                                                                            {
                                                                                return .codable(thing)
                                                                            }
                                                                            else
                                                                            {
                                                                                return .uncodable(data)
                                                                            }
                                                                            
                                                                        @unknown default:
                                                                            fatalError()
                                                                        }
                                                                        
                                                                    }
                                                                    
            
            _ = self?.subscriber?.receive(newResult)
            self?.receive()
            /*
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
             */
           }
  
       }
}


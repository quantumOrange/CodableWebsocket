//
//  CodableWebsocketSubscription.swift
//  CodableWebSocketExample
//
//  Created by David Crooks on 18/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation
import Combine

final class CodableWebsocketSubscription<SubscriberType: Subscriber, T: Codable>: Subscription where SubscriberType.Input == Result<SocketData<T>,Error>,SubscriberType.Failure == Error {
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
                                                                    
            
            if case Result.failure(let error) = newResult, self?.webSocketTask.closeCode != .invalid {
                self?.subscriber?.receive(completion:Subscribers.Completion.failure(error))
            }
            else {
                _ = self?.subscriber?.receive(newResult)
            }
            
            self?.receive()
            
           }
  
       }
}


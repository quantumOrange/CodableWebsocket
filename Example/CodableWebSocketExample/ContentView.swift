//
//  ContentView.swift
//  WebSocketDemo
//
//  Created by David Crooks on 07/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import SwiftUI
import Combine
import CodableWebSocket

class ViewModel:ObservableObject {
    var socket:CodableWebSocket<Thing>
    var cancelable:AnyCancellable? = nil
    
    @Published var thing:Thing = Thing(name: "nothing", number: 0)
    
    init() {
        socket = CodableWebSocket<Thing>(url:URL(string:"ws://echo.websocket.org")!)
        
        cancelable  =     socket
                            .codable()
                            .receive(on:DispatchQueue.main)
                            .filterOutErrors()
                            .assign(to: \ViewModel.thing, on: self)
                                
    }
}

struct ContentView: View
{
    @ObservedObject var viewModel:ViewModel = ViewModel()
    
    var body: some View
    {
        VStack
        {
            Text("Received: \(viewModel.thing.name). Thing number \(viewModel.thing.number).")
            Button("Send A Thing")
            {
                _ = self
                    .viewModel
                    .socket
                    .receive(.codable(self.viewModel.thing.next()))
            }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View
    {
        ContentView()
    }
}

//
//  Thing.swift
//  WebSocketDemo
//
//  Created by David Crooks on 07/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation

struct Thing:Codable {
    let name:String
    let number:Int
    
    
    func next() -> Thing {
        let name = Thing.names[number % Thing.names.count]
        return Thing(name: name, number: number+1)
    }
    
    static let names = ["Banana","Grapes","Bicycle","Surfboard","Octopus","Drill","Book"]
}

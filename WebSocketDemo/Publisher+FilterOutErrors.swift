//
//  Publisher+FilterOutErrors.swift
//  WebSocketDemo
//
//  Created by David Crooks on 07/09/2020.
//  Copyright © 2020 David Crooks. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    func filterOutErrors() -> Publishers.CompactMap<Publishers.ReplaceError<Publishers.Map<Self, Self.Output?>>, Self.Output>
    {
        map{ Optional($0)}
            .replaceError(with:nil)
            .compactMap{$0}
    }
}

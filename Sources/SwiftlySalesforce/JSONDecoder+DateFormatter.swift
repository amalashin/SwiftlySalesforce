//
//  JSONDecoder+DateFormatter.swift
//  SwiftlySalesforce
//
//  For license & details see: https://www.github.com/mike4aday/SwiftlySalesforce
//  Copyright (c) 2019. All rights reserved.

import Foundation

public extension JSONDecoder {
    
    convenience init(dateFormatter: DateFormatter) {
        self.init()
        self.dateDecodingStrategy = .formatted(dateFormatter)
    }
}

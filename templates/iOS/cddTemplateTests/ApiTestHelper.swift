//
//  APIFaker.swift
//  Test1Tests
//
//  Created by Alexei on 21/09/2019.
//  Copyright © 2019 Alexei. All rights reserved.
//

import UIKit

class APIFaker {
    static var string: String {
        return UUID().uuidString.components(separatedBy: "-").first!
    }
    static var int: Int {
        return Int.random(in: 0...100)
    }
    static var bool: Bool {
        return Int.random(in: 0...1) == 0
    }
    static var float: Float {
        return Float.random(in: 0...100)
    }
}

extension Encodable {
    var jsonString: String {
        guard let data = try? JSONEncoder().encode(self) else { return "{}" }
        
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

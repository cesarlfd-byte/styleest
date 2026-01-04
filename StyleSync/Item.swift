//
//  Item.swift
//  StyleSync
//
//  Created by Cesar Gama Camboim on 03/01/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}


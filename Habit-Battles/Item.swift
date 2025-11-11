//
//  Item.swift
//  Habit-Battles
//
//  Created by Mike Gweth Lango on 11/10/25.
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

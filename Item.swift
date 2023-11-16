//
//  Item.swift
//  GroceryList
//
//  Created by Asir Bygud on 11/15/23.
//

import Foundation
import SwiftData

@Model
class Item {
    var creationDate: Date = Date()
    var name: String = ""
    var complete: Bool = false
    
    init(creationDate: Date, name: String, complete: Bool) {
        self.creationDate = creationDate
        self.name = name
        self.complete = complete
    }
}

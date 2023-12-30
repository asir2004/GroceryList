//
//  GroceryItemView.swift
//  GroceryList
//
//  Created by Asir Bygud on 11/16/23.
//

import Foundation
import SwiftUI

struct GroceryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @FocusState var focusState: Bool
    var item: Item
    
    init(item: Item) {
        self.name = item.name
        self.item = item
    }
    
    var body: some View {
        TextField("Grocery Item", text: $name)
            .focused($focusState)
            .strikethrough(item.complete)
            .foregroundStyle(item.complete ? .secondary : .primary)
//                .strikethrough(item.complete)
            .onChange(of: name, {
                item.name = name
            })
    }
}

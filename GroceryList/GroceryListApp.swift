//
//  GroceryListApp.swift
//  GroceryList
//
//  Created by Asir Bygud on 11/15/23.
//

import SwiftUI
import SwiftData

@main
struct GroceryListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 300, height: 700)
        .windowResizability(.contentSize)
    }
}

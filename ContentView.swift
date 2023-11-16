//
//  ContentView.swift
//  GroceryList
//
//  Created by Asir Bygud on 11/15/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.creationDate, order: .reverse) private var items: [Item]
    @State private var name: String = ""
    @State private var largeTitle = true
    @FocusState private var focusState: Bool

    var body: some View {
        NavigationStack {
            List {
                HStack {
                    TextField("New Item", text: $name)
                        .focused($focusState)
                        .onSubmit {
                            if name != "" {
                                addItem()
                            }
                            focusState = true
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .submitLabel(.continue)
                    
                    Button("Save") {
                        addItem()
                    }
                    .buttonStyle(.bordered)
                    .disabled(name == "")
                }
                .listRowSeparator(.visible, edges: .bottom)
                
                ForEach(items) { item in
                    HStack {
                        Image(systemName: item.complete ? "checkmark.circle" : "circle")
                            .onTapGesture {
                                withAnimation {
                                    item.complete.toggle()
                                    #if os(iOS)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    #endif
                                }
                            }
                            .foregroundStyle(.mint)
                            .imageScale(.large)
                            .foregroundStyle(Color.accentColor)
                            .symbolEffect(.bounce.down, value: item.complete)
                        
                        GroceryItemView(item: item)
                        
//                        Text(item.name)
//                            .foregroundStyle(item.complete ? .secondary : .primary)
//                            .strikethrough(item.complete)
                        
                        Spacer()
                        
                        Button("Delete") {
                            modelContext.delete(item)
                        }
                        .foregroundStyle(.red)
                        .buttonStyle(.bordered)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .onAppear(perform: {
                focusState = true
            })
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        focusState = false
                    }
                }
            }
            .listStyle(.plain)
            .padding(.top, largeTitle ? 80 : 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: largeTitle ? .topLeading : .top) {
                Text("Grocery: \(items.count)")
                    .font(largeTitle ? .largeTitle : .headline).bold()
                    .padding(.top, largeTitle ? 30 : 10)
                    .padding(.horizontal)
                    .contentTransition(.numericText(value: Double(items.count)))
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(creationDate: Date(), name: name, complete: false)
            modelContext.insert(newItem)
            name = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

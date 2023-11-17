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
    @State private var showDeleteAllAlert = false
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
                            .symbolEffect(.bounce.down, options: .speed(1.2), value: item.complete)
                        
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
                HStack(spacing: 0) {
                    Text("Grocery: ")
                        .font(largeTitle ? .largeTitle : .headline).bold()
                        .foregroundStyle(.tertiary)
                    Text("\(calculateUncompletedCount())")
                        .font(largeTitle ? .largeTitle : .headline).bold()
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText(countsDown: true))
                    Text(": \(items.count)")
                        .font(largeTitle ? .largeTitle : .headline).bold()
                        .contentTransition(.numericText(countsDown: true))
                }
                .padding(.top, largeTitle ? 30 : 10)
                .padding(.horizontal)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    showDeleteAllAlert = true
                } label: {
                    Label("Delete All", systemImage: "trash")
                }
                .labelStyle(.iconOnly)
                .padding()
            }
            .alert("Delete All Items?", isPresented: $showDeleteAllAlert) {
                Button("Confirm", role: .destructive) {
                    deleteAll()
                }
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
    
    private func deleteAll() {
        for item in items {
            modelContext.delete(item)
        }
    }
    
    func calculateUncompletedCount() -> Int {
        var count = 0
        for item in items {
            if !item.complete {
                count += 1
            }
        }
        return count
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

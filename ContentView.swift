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
    @State private var showCompleted = false
    @FocusState private var focusState: Bool
    @State private var testViewIsPresented = false
    @AppStorage("swipeToDeleteIsOn") var swipeToDeleteIsOn = false

    var body: some View {
        NavigationStack {
            VStack {
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
                .padding(7)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.ultraThinMaterial)
                )
                .padding(.horizontal)
                
                List {
                    ForEach(items) { item in
                        if !item.complete || showCompleted {
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
                                
                                if !swipeToDeleteIsOn {
                                    Button("Delete") {
                                        modelContext.delete(item)
                                    }
                                    .foregroundStyle(.red)
                                    .buttonStyle(.bordered)
                                    .frame(height: 20)
                                }
                            }
                            .listRowSeparator(.visible, edges: .top)
                        }
                    }
                    .onDelete(perform: swipeToDeleteIsOn ? deleteItems : nil)
                }
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
            .overlay {
                if items.isEmpty {
                    VStack {
                        Image(systemName: "checklist")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .foregroundStyle(.tertiary)
                            .padding(6)
                        Text("No Items")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
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
                HStack {
                    Menu {
                        Button {
                            showDeleteAllAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                
                                Text("Delete All")
                            }
                        }
                        
                        Toggle(isOn: $showCompleted) {
                            HStack {
                                Image(systemName: "checkmark")
                                
                                Text("Show Completed")
                                
                                Spacer()
                                
                                if showCompleted {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Toggle(isOn: $swipeToDeleteIsOn) {
                            HStack {
                                Image(systemName: "arrow.left")
                                
                                Text("Swipe to Delete")
                                
                                Spacer()
                                
                                if swipeToDeleteIsOn {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                    .labelStyle(.iconOnly)
                    
                    Button {
                        testViewIsPresented.toggle()
                    } label: {
                        Label("Show Completed", systemImage: "questionmark")
                    }
                    .labelStyle(.iconOnly)
                    .padding()
                }
            }
            .alert("Delete All Items?", isPresented: $showDeleteAllAlert) {
                Button("Confirm", role: .destructive) {
                    deleteAll()
                }
            }
            .sheet(isPresented: $testViewIsPresented, content: {
                AnimationTestView()
            })
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

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

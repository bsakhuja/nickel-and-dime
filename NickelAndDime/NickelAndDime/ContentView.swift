//
//  ContentView.swift
//  NickelAndDime
//
//  Created by Brian Sakhuja on 5/18/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var selectedDate = Date()
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM y"
        
        return dateFormatter
    }
    
    @State private var income = [Transaction]()
    @State private var expenses = [Transaction]()
    
    @State var field1: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Income"),
                        footer: Button(action: addIncome) {
                            Text("+ Add Income")
                        })
                {
                    ForEach(income, id: \.self) { incomeLine in
                        Text(incomeLine.name)
                    }
                }
                Section(header: Text("Expenses"),
                        footer: Button(action: addExpense) {
                            Text("+ Add Expense")
                        })
                {
                    ForEach(expenses, id: \.self) { expenseLine in
                        Text(expenseLine.name)
                    }
                }
            }
            .navigationBarTitle(dateFormatter.string(from: selectedDate))
            .navigationBarItems(trailing:
                                    HStack {
                                        Button(action: previousMonth) {
                                            Image(systemName: "chevron.left.circle")
                                                .resizable()
                                                .frame(width: 32, height: 32, alignment: .center)
                                        }
                                        Button(action: nextMonth) {
                                            Image(systemName: "chevron.right.circle")
                                                .resizable()
                                                .frame(width: 32, height: 32, alignment: .center)
                                        }
                                    }
//                                    ZStack {
//                                        DatePicker("label", selection: $date, displayedComponents: .date)
//                                            .datePickerStyle(CompactDatePickerStyle())
//                                            .labelsHidden()
//                                        Button(action: addItem) {
//                                            Image(systemName: "calendar")
//                                                .resizable()
//                                                .frame(width: 32, height: 32, alignment: .center)
//                                        }
//
//                                    }
            )
        }
    }
    
    private func previousMonth() {
        withAnimation {
            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)
            selectedDate = previousMonth ?? Date()
        }
    }
    
    private func nextMonth() {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)
        selectedDate = nextMonth ?? Date()
    }
    
    private func addIncome() {
        income.append(Transaction(name: "example income", value: 23.0, month: selectedDate))
    }

    private func addExpense() {
        expenses.append(Transaction(name: "example expense", value: 23.0, month: selectedDate))
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct Transaction: Hashable {
    let name: String
    let value: Double
    let month: Date
}

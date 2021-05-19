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
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }
    
    @StateObject var store = BudgetStore()
    
    @State var transactionName: String = ""
    @State var transactionAmount: Double = 0
    
    var someNumberProxy: Binding<String> {
            Binding<String>(
                get: { String(format: "$%.02f", self.transactionAmount) },
                set: {
                    if let value = numberFormatter.number(from: $0) {
                        self.transactionAmount = value.doubleValue
                    }
                }
            )
        }

    
    var body: some View {
        NavigationView {
            List {
                Text(String(format: "Net income $%.2f", netIncome))
                Section(
                    header: Text(String(format: "Income $%.2f",
                                        sum(transactions: store.income))).foregroundColor(Color.green),
                    footer: Button(action: addIncome) {
                        Text("+ Add income")
                    })
                {
                    ForEach(store.income, id: \.self) { incomeLine in
                        TransactionRow(transaction: incomeLine)
                        
                    }
                }
                Section(header: Text(String(format: "Expenses -$%.2f", sum(transactions: store.expenses))).foregroundColor(Color.red),
                        footer: Button(action: addExpense) {
                            Text("+ Add expense")
                        })
                {
                    ForEach(store.expenses, id: \.self) { expenseLine in
                        TransactionRow(transaction: expenseLine)
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
        withAnimation {
            store.income.append(Transaction(name: $transactionName, value: Binding<Double>.constant(0), month: selectedDate, isIncome: true))
        }
    }

    private func addExpense() {
        withAnimation {
        store.expenses.append(Transaction(name: $transactionName, value: Binding<Double>.constant(0), month: selectedDate))
        }
    }
    
    private func sum(transactions: [Transaction]) -> Double {
        return transactions.compactMap { $0.value }
            .reduce(0, +)
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
    
    var netIncome: Double {
        sum(transactions: store.income) - sum(transactions: store.expenses)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct Transaction: Hashable, Identifiable {
    @Binding var name: String
    @Binding var value: Double
    var month: Date
    var isIncome: Bool = false
    var id = UUID()
    
    // MARK: - Hashable Conformance
    
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

final class BudgetStore: ObservableObject {
    @Published var income = [Transaction]()
    @Published var expenses = [Transaction]()
}

struct TransactionRow: View {
    var transaction = Transaction(name: Binding<String>.constant(""), value: Binding<Double>.constant(0), month: Date())
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }
    
    var stringFormat: String {
        return transaction.isIncome ? "$%.02f" : "-$%.02f"
    }
    
    var textFieldPlaceholder: String {
        return transaction.isIncome ? "New income" : "New expense"
    }
    
    var someNumberProxy: Binding<String> {
            Binding<String>(
                get: { String(format: stringFormat, self.transaction.value) },
                set: {
                    if let value = numberFormatter.number(from: $0) {
                        self.transaction.value = value.doubleValue
                    }
                }
            )
        }
    
    var body: some View {
        HStack {
            TextField(
                textFieldPlaceholder,
                text: transaction.$name)
            Spacer()
            TextField(
                "Amount",
                text: someNumberProxy)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(transaction.isIncome ? Color.green : Color.red)
        }
    }
}

//
//  AddExpenseView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ExpenseViewModel

    // Form State
    @State private var amountText = ""
    @State private var selectedCategory = "Food"
    @State private var showAlert = false
    // NEW: State for recurring expenses
    @State private var isRecurring = false
    @State private var frequency = "Monthly"

    let categories = ["Food", "Transport", "Entertainment", "Shopping", "Other"]
    let frequencies = ["Daily", "Weekly", "Monthly"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("Enter amount", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)
                }
                
                // NEW: Section for recurring expenses
                Section(header: Text("Recurring Expense")) {
                    Toggle("Make this a recurring expense", isOn: $isRecurring.animation())
                    
                    if isRecurring {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(frequencies, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Button(action: saveExpense) {
                    Text("Save Expense")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .tint(.blue)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Invalid Input", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid amount greater than 0.")
            }
        }
    }

    private func saveExpense() {
        guard let amount = Double(amountText), amount > 0 else {
            showAlert = true
            return
        }
        // UPDATED: Pass new recurring data to the ViewModel
        viewModel.addExpense(
            amount: amount,
            category: selectedCategory,
            isRecurring: isRecurring,
            frequency: isRecurring ? frequency : nil
        )
        dismiss()
    }
}

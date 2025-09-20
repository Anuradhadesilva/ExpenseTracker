//
//  ExpenseListView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    
    // A shared source for categories
    let categories = ["All", "Food", "Transport", "Entertainment", "Shopping", "Other"]
    
    var body: some View {
        // Use a NavigationView to host the search bar correctly
        NavigationStack {
            VStack {
                // Category Filter Picker
                Picker("Filter by Category", selection: $viewModel.selectedCategoryFilter) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // The list now uses the `filteredExpenses` array
                List {
                    ForEach(viewModel.filteredExpenses) { expense in // No need for id: \.id anymore
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.category)
                                    .fontWeight(.semibold)
                                Text(expense.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("$\(expense.amount, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                    }
                    .onDelete { indexSet in
                        // Make sure to delete from the filtered list to get the correct item
                        indexSet.map { viewModel.filteredExpenses[$0] }.forEach(viewModel.deleteExpense)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Expenses")
            .navigationBarHidden(true) // Hide the nav title bar as it's inside another view
        }
        // This modifier adds the search bar UI and binds it to our ViewModel property
        .searchable(text: $viewModel.searchText, prompt: "Search by Category")
    }
}

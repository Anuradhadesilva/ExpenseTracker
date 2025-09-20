//
//  ExpenseTrackerView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import SwiftUI

struct ExpenseTrackerView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showAddExpense = false

    var body: some View {
        // UPDATED: The entire view is now a TabView for better navigation.
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
            
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
                
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// NEW: The original view is now extracted into its own component for the first tab.
struct DashboardView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel
    @State private var showAddExpense = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    LimitProgressView(spent: viewModel.totalSpentToday(), limit: viewModel.dailyLimit, title: "Daily Limit")
                    LimitProgressView(spent: viewModel.totalSpentThisWeek(), limit: viewModel.weeklyLimit, title: "Weekly Limit")
                    LimitProgressView(spent: viewModel.totalSpentThisMonth(), limit: viewModel.monthlyLimit, title: "Monthly Limit")
                    ChartsView()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                // NEW: ShareLink for CSV Export
                ToolbarItem(placement: .navigationBarLeading) {
                    ShareLink(item: viewModel.generateCSV() ?? URL(string: "https://apple.com")!,
                              subject: Text("My Expenses Export"),
                              message: Text("Here are my expenses from the tracker app.")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView().environmentObject(viewModel)
            }
        }
    }
}

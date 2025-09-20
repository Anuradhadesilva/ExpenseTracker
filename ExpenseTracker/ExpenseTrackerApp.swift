//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    // UPDATED: The ViewModel is now created once here and passed down.
    @StateObject private var viewModel = ExpenseViewModel()
    
    var body: some Scene {
        WindowGroup {
            // UPDATED: The root view is now the main ExpenseTrackerView which contains the TabView.
            ExpenseTrackerView()
                .environmentObject(viewModel)
                .onAppear {
                    // NEW: Process any due recurring expenses when the app starts.
                    viewModel.processRecurringExpenses()
                }
        }
    }
}

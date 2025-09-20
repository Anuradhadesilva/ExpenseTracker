//
//  SettingView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Monthly Budget Limits")) {
                    // These TextFields bind directly to the @AppStorage
                    // properties in the ViewModel. Changes are saved automatically.
                    HStack {
                        Text("Daily Limit")
                        Spacer()
                        TextField("Daily Limit", value: $viewModel.dailyLimit, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Weekly Limit")
                        Spacer()
                        TextField("Weekly Limit", value: $viewModel.weeklyLimit, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Monthly Limit")
                        Spacer()
                        TextField("Monthly Limit", value: $viewModel.monthlyLimit, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("About"), footer: Text("This app helps you track your daily expenses and stay within budget.")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

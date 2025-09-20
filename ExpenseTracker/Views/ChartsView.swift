//
//  ChartsView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//
import SwiftUI
import Charts

struct ChartsView: View {
    @EnvironmentObject var viewModel: ExpenseViewModel

    // This local struct is a good pattern for chart data
    struct SpendingData: Identifiable {
        let id = UUID()
        let period: String
        let spent: Double
        let limit: Double
    }

    var data: [SpendingData] {
        [
            SpendingData(period: "Today", spent: viewModel.totalSpentToday(), limit: viewModel.dailyLimit),
            SpendingData(period: "Week", spent: viewModel.totalSpentThisWeek(), limit: viewModel.weeklyLimit),
            SpendingData(period: "Month", spent: viewModel.totalSpentThisMonth(), limit: viewModel.monthlyLimit)
        ]
    }

    var body: some View {
        Chart {
            ForEach(data) { item in
                let spentValue = Int(item.spent)
                let limitValue = Int(item.limit)

                // Spent Bar
                BarMark(
                    x: .value("Period", item.period),
                    y: .value("Spent", item.spent)
                )
                .foregroundStyle(item.spent > item.limit ? .red : .green)
                .annotation(position: .top) {
                    Text("$\(spentValue)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Limit Line (only show if limit is greater than 0)
                if item.limit > 0 {
                    RuleMark(y: .value("Limit", item.limit))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(.blue)
                        .annotation(position: .bottom, alignment: .leading) {
                            Text("Limit: $\(limitValue)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                }
            }
        }
        .chartYScale(domain: 0...((data.map { $0.limit }.max() ?? 0) * 1.2)) // Give some headroom on Y axis
        .animation(.easeInOut, value: data.map { $0.spent })
        .frame(height: 250)
        .padding()
        .background(.bar) // Adapts to light/dark mode
        .cornerRadius(12)
    }
}

//
//  LimitProgressView.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import SwiftUI

struct LimitProgressView: View {
    var spent: Double
    var limit: Double
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                // Format as currency for better readability
                Text("\(spent, format: .currency(code: "USD").precision(.fractionLength(0))) / \(limit, format: .currency(code: "USD").precision(.fractionLength(0)))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: spent, total: limit > 0 ? limit : 1)
                .tint(progressColor())
                .animation(.easeInOut, value: spent)

            if limit > 0 {
                Text("\(Int((spent / limit) * 100))% of limit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Limit not set")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.bar) // More adaptive than ultraThinMaterial
        .cornerRadius(12)
    }

    private func progressColor() -> Color {
        guard limit > 0 else { return .gray }
        let percent = spent / limit
        
        switch percent {
        case ..<0.8: return .green
        case 0.8..<1.0: return .yellow
        default: return .red
        }
    }
}

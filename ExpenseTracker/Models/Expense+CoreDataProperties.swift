//
//  Expense+CoreDataProperties.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//


import Foundation
import CoreData

extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    // --- Existing Attributes ---
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    
    // --- NEW: Attributes for Recurring Expenses ---
    @NSManaged public var isRecurring: Bool       // Type: Boolean, Default: false
    @NSManaged public var frequency: String?      // Type: String, Mark as Optional
    @NSManaged public var nextDueDate: Date?      // Type: Date, Mark as Optional
}

extension Expense: Identifiable {

}

//
//  Untitled.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-24.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    // --- All Attributes ---
    @NSManaged public var id: UUID
    @NSManaged public var name: String?
    @NSManaged public var symbolName: String?
    @NSManaged public var colorData: Data?
    
    // --- Relationship ---
    @NSManaged public var expenses: NSSet?

}

// MARK: Generated accessors for expenses
extension Category {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expense)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expense)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

extension Category : Identifiable {

}

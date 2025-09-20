//
//  PersistenceController.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "ExpenseModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}

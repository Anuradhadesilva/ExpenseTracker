//
//  ExpenseViewModel.swift
//  ExpenseTracker
//
//  Created by De Silva Anuradha on 2025-09-20.
//
import SwiftUI
import CoreData
import UserNotifications // NEW: Import for notifications

class ExpenseViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // --- Data Arrays ---
    private var allExpenses: [Expense] = []
    @Published var filteredExpenses: [Expense] = []
    
    // --- Filter & Search State ---
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }
    @Published var selectedCategoryFilter: String = "All" {
        didSet { applyFilters() }
    }
    
    // --- Persistent User-defined Limits ---
    @AppStorage("dailyLimit") var dailyLimit: Double = 100
    @AppStorage("weeklyLimit") var weeklyLimit: Double = 500
    @AppStorage("monthlyLimit") var monthlyLimit: Double = 2000
    
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchExpenses()
        requestNotificationPermission() // NEW: Ask for permission on init
    }
    
    // MARK: - Core Data CRUD
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            allExpenses = try context.fetch(request)
            applyFilters()
        } catch {
            print("Failed to fetch expenses: \(error.localizedDescription)")
            allExpenses = []; filteredExpenses = []
        }
    }
    
    // UPDATED: addExpense now handles recurring properties
    func addExpense(amount: Double, category: String, date: Date = Date(), isRecurring: Bool, frequency: String?) {
        let expense = Expense(context: context)
        expense.id = UUID()
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.isRecurring = isRecurring
        
        if isRecurring, let freq = frequency {
            expense.frequency = freq
            if let nextDate = calculateNextDueDate(from: date, frequency: freq) {
                expense.nextDueDate = nextDate
                scheduleNotification(for: expense) // NEW: Schedule reminder
            }
        }
        
        saveContext()
    }
    
    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchExpenses()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Feature Logic
    
    private func applyFilters() {
        var result = allExpenses.filter { !$0.isRecurring } // Don't show master recurring expenses in the list

        if !searchText.isEmpty {
            result = result.filter { $0.category.lowercased().contains(searchText.lowercased()) }
        }

        if selectedCategoryFilter != "All" {
            result = result.filter { $0.category == selectedCategoryFilter }
        }
        
        filteredExpenses = result
    }
    
    // NEW: Logic for recurring expenses
    func processRecurringExpenses() {
        let now = Date()
        let recurring = allExpenses.filter { $0.isRecurring }
        
        for expense in recurring {
            if let dueDate = expense.nextDueDate, dueDate <= now {
                // Add a new, non-recurring expense
                addExpense(amount: expense.amount, category: expense.category, date: dueDate, isRecurring: false, frequency: nil)
                
                // Update the next due date for the template
                if let nextDate = calculateNextDueDate(from: dueDate, frequency: expense.frequency ?? "") {
                    expense.nextDueDate = nextDate
                    scheduleNotification(for: expense) // Reschedule notification
                }
            }
        }
        saveContext()
    }

    private func calculateNextDueDate(from date: Date, frequency: String) -> Date? {
        var dateComponent = DateComponents()
        switch frequency {
            case "Daily": dateComponent.day = 1
            case "Weekly": dateComponent.weekOfYear = 1
            case "Monthly": dateComponent.month = 1
            default: return nil
        }
        return Calendar.current.date(byAdding: dateComponent, to: date)
    }

    // NEW: CSV Export Logic
    func generateCSV() -> URL? {
        let fileName = "expenses-\(Date().formatted()).csv"
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else { return nil }
        
        var csvText = "Date,Category,Amount\n"
        let exportableExpenses = allExpenses.filter { !$0.isRecurring }
        
        for expense in exportableExpenses {
            csvText.append("\(expense.date.formatted(date: .abbreviated, time: .omitted)),\(expense.category),\(expense.amount)\n")
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            return path
        } catch {
            print("Failed to create CSV: \(error.localizedDescription)")
            return nil
        }
    }
    
    // NEW: Notification Logic
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Notification permission granted: \(granted)")
        }
    }
    
    private func scheduleNotification(for expense: Expense) {
        guard let dueDate = expense.nextDueDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Recurring Expense Due"
        content.body = "Your \(expense.frequency?.lowercased() ?? "") expense of $\(expense.amount) for \(expense.category) is due."
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: expense.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Calculations
    func totalSpentToday() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return allExpenses.filter { !$0.isRecurring && $0.date >= today }.reduce(0) { $0 + $1.amount }
    }
    
    func totalSpentThisWeek() -> Double {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return allExpenses.filter { !$0.isRecurring && $0.date >= weekStart }.reduce(0) { $0 + $1.amount }
    }
    
    func totalSpentThisMonth() -> Double {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: Date())?.start else { return 0 }
        return allExpenses.filter { !$0.isRecurring && $0.date >= monthStart }.reduce(0) { $0 + $1.amount }
    }
}

//
//  TransactionsDataRepository.swift
//  Transactions
//
//  Created by Eduardo García on 10/12/22.
//

import Foundation
import CoreData

protocol TransactionsDataRepositorable {
    var context: NSManagedObjectContext { get set }
    func set(key: String, value: String)
    func get(key: String) -> Transactions?
    func delete(key: String)
    func commit() -> Error?
    func rollback()
    func count(value: String) -> Int
}



final class TransactionsDataRepository: TransactionsDataRepositorable {
    internal var context: NSManagedObjectContext
    private let fetchRequest: NSFetchRequest<Transactions> = Transactions.fetchRequest()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func set(key: String, value: String) {
        delete(key: key)
        let transaction = Transactions(context: context)
        transaction.key = key
        transaction.value = value
    }
    
    func get(key: String) -> Transactions? {
        let predicate: NSPredicate = NSPredicate(format: "key == %@", key)
        fetchRequest.predicate = predicate
        return try? context.fetch(fetchRequest).first
    }
    
    func delete(key: String) {
        guard let transaction = get(key: key) else { return }
        context.delete(transaction)
    }
    
    func count(value: String) -> Int {
        let predicate: NSPredicate = NSPredicate(format: "value == %@", value)
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest).count
        } catch {
            return 0
        }
    }
    
    func commit() -> Error? {
        do {
            try context.save()
            return nil
        } catch {
            return error
        }
    }
    
    func rollback() {
        context.rollback()
    }
}

//
//  TransactionsDataStack.swift
//  TransactionsTests
//
//  Created by Eduardo García on 11/12/22.
//

@testable import Transactions
import CoreData

final class TransactionsDataStack: Transactions {
    lazy var persistenContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "Transactions")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
}

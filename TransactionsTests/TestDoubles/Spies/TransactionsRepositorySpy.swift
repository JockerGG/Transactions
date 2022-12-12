//
//  TransactionsRepositorySpy.swift
//  TransactionsTests
//
//  Created by Eduardo García on 11/12/22.
//

import Foundation
import CoreData
@testable import Transactions

final class TransactionsRepositorySpy: TransactionsDataRepositorable {
    // MARK: - Spy: TransactionsDataRepositorable
    
    var contextGetterCalled: Bool { contextGetterCallCount > 0 }
    var contextGetterCallCount: Int = 0
    var contextSetterCalled: Bool { contextSetterCallCount > 0 }
    var contextSetterCallCount: Int = 0
    var contextParameter: NSManagedObjectContext?
    var contextParameterList: [NSManagedObjectContext] = []
    var stubbedContext: NSManagedObjectContext!
    
    var context: NSManagedObjectContext {
        get {
            contextGetterCallCount += 1
            return stubbedContext
        }
        set {
            contextSetterCallCount += 1
            contextParameter = newValue
            contextParameterList.append(newValue)
        }
    }
    
    var getCalled: Bool { getCallCount > 0 }
    var getCallCount: Int = 0
    var getParameters: (key: String, Void)?
    var getParameterList: [(key: String, Void)] = []
    var getResult: Transactions? = nil
    
    func get(key: String) -> Transactions? {
        getCallCount += 1
        getParameters = (key, ())
        getParameterList.append((key, ()))
        return getResult
    }
    
    var setCalled: Bool { setCallCount > 0 }
    var setCallCount: Int = 0
    var setParameters: (key: String, value: String)?
    var setParameterList: [(key: String, value: String)] = []
    
    func set(key: String, value: String) {
        setCallCount += 1
        setParameters = (key, value)
        setParameterList.append((key, value))
    }
    
    var commitCalled: Bool { commitCallCount > 0 }
    var commitCallCount: Int = 0
    var commitResult: Error? = nil
    
    func commit() -> Error? {
        commitCallCount += 1
        return commitResult
    }
    
    var countCalled: Bool { countCallCount > 0 }
    var countCallCount: Int = 0
    var countParameters: (value: String, Void)?
    var countParameterList: [(value: String, Void)] = []
    var countResult: Int! = 0
    
    func count(value: String) -> Int {
        countCallCount += 1
        countParameters = (value, ())
        countParameterList.append((value, ()))
        return countResult
    }
    
    var deleteCalled: Bool { deleteCallCount > 0 }
    var deleteCallCount: Int = 0
    var deleteParameters: (key: String, Void)?
    var deleteParameterList: [(key: String, Void)] = []
    
    func delete(key: String) {
        deleteCallCount += 1
        deleteParameters = (key, ())
        deleteParameterList.append((key, ()))
    }
    
    var rollbackCalled: Bool { rollbackCallCount > 0 }
    var rollbackCallCount: Int = 0
    
    func rollback() {
        rollbackCallCount += 1
    }
}

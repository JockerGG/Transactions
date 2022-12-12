//
//  TransactionsLogBuilder.swift
//  Transactions
//
//  Created by Eduardo García on 10/12/22.
//

import Foundation

enum TransactionLogBuilder {
    static func build(key: String? = nil,
                      value: String? = nil,
                      storedValue: String? = nil,
                      action: String) -> String {
        var logRegister = "> \(action)"
        if let key = key {
            logRegister.append(" \(key)")
        }
        
        if let value = value {
            logRegister.append(" \(value)")
        }
        
        if let storedValue = storedValue {
            logRegister.append("\n\(storedValue)")
        }
        
        logRegister.append("\n")
        
        return logRegister
    }
}


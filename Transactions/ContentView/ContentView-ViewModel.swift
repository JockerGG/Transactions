//
//  ContentView-ViewModel.swift
//  Transactions
//
//  Created by Eduardo García on 09/12/22.
//

import Foundation
import CoreData
import SwiftUI

enum Actions: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case set
    case get
    case delete
    case count
    
    var name: String {
        self.rawValue.capitalizingFirstLetter()
    }
}

enum TransactionActions: String, CaseIterable, Identifiable {
    var id: Self { self }
    
    case begin
    case commit
    case rollback
    
    var name: String {
        self.rawValue.capitalizingFirstLetter()
    }
}

extension ContentView {
    @MainActor final class ViewModel: ObservableObject {
        private let transactionDataRepository: TransactionsDataRepositorable
        @Published var consoleLog: String = ""
        @Published private(set) var isTransactionActive: Bool = false
        @Published private(set) var actionSelected: Actions = .set
        @Published private(set) var showValueTextField: Bool = false
        @Published private(set) var executeButtonIsEnabled: Bool = false
        @Published var key: String = "" {
            didSet {
                shouldEnableButton()
            }
        }
        @Published var dataValue: String = "" {
            didSet {
                shouldEnableButton()
            }
        }
        
        init(transactionDataRepository: TransactionsDataRepositorable) {
            self.transactionDataRepository = transactionDataRepository
            setAction(.set)
        }
        
        func setAction(_ action: Actions) {
            actionSelected = action
            showValueTextField = (action == .set || action == .count)
        }
        
        func shouldEnableTransactionButton(action: TransactionActions) -> Bool {
            switch action {
            case .begin:
                return !isTransactionActive
            case .commit, .rollback:
                return isTransactionActive
            }
        }
        
        func execute() {
            let logRegister: String
            switch actionSelected {
            case .set:
                guard !dataValue.isEmpty else { return }
                transactionDataRepository.set(key: key, value: dataValue)
                logRegister = TransactionLogBuilder.build(key: self.key, value: self.dataValue, action: self.actionSelected.name)
            case .get:
                if let transaction = transactionDataRepository.get(key: key) {
                    logRegister = TransactionLogBuilder.build(key: key, storedValue: transaction.value, action: actionSelected.name)
                } else {
                    logRegister = TransactionLogBuilder.build(key: key, storedValue: "Key not set", action: actionSelected.name)
                }
            case .delete:
                transactionDataRepository.delete(key: key)
                logRegister = TransactionLogBuilder.build(key: key, action: actionSelected.name)
            case .count:
                guard !dataValue.isEmpty else { return }
                let count = transactionDataRepository.count(value: dataValue)
                logRegister = TransactionLogBuilder.build(key: key, storedValue: String(describing: count), action: actionSelected.name)
            }
            
            if actionSelected == .set || actionSelected == .delete {
                if !isTransactionActive {
                    if let error = transactionDataRepository.commit() {
                        handleError(error)
                    }
                }
            }
            key = ""
            dataValue = ""
            consoleLog.append(logRegister)
        }
        
        func execute(transactionAction: TransactionActions) {
            if case .commit = transactionAction {
                if let error = transactionDataRepository.commit() {
                    handleError(error)
                    return
                }
            }
            
            if case .rollback = transactionAction {
                transactionDataRepository.rollback()
            }
            
            isTransactionActive = transactionAction == .begin
            registerLog(action: transactionAction.name)
        }
        
        private func shouldEnableButton() {
            switch actionSelected {
            case .delete, .get:
                executeButtonIsEnabled = !key.isEmpty
            case .set:
                executeButtonIsEnabled = (!key.isEmpty && !dataValue.isEmpty)
            case .count:
                executeButtonIsEnabled = !dataValue.isEmpty
            }
        }
        
        private func registerLog(key: String? = nil,
                                 value: String? = nil,
                                 storedValue: String? = nil,
                                 action: String) {
            consoleLog.append(TransactionLogBuilder.build(key: key,
                                                          value: value,
                                                          storedValue: storedValue,
                                                          action: action))
        }
        
        private func handleError(_ error: Error) {
            print(error.localizedDescription)
        }
    }
}

private extension String {
    static let selectedAction: String = "Selected action: %@"
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

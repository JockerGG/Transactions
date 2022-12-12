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
        typealias AlertAction = () -> ()
        private let transactionDataRepository: TransactionsDataRepositorable
        var alertAction: AlertAction?
        @Published var consoleLog: String = ""
        @Published var alertTitle: String = ""
        @Published private(set) var isTransactionActive: Bool = false
        @Published private(set) var actionSelected: Actions = .set
        @Published private(set) var showValueTextField: Bool = false
        @Published private(set) var executeButtonIsEnabled: Bool = false
        @Published var isAlertShowed: Bool = false
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
            switch actionSelected {
            case .set:
                guard !dataValue.isEmpty else { return }
                transactionDataRepository.set(key: key, value: dataValue)
                registerLog(key: key, value: dataValue, action: actionSelected.name)
            case .get:
                if let transaction = transactionDataRepository.get(key: key) {
                    registerLog(key: key, storedValue: transaction.value, action: actionSelected.name)
                } else {
                    registerLog(key: key, storedValue: "Key not set", action: actionSelected.name)
                }
            case .delete:
                showAlert(title: "Are you sure to delete?") { [weak self] in
                    guard let self = self else { return }
                    self.transactionDataRepository.delete(key: self.key)
                    self.registerLog(key: self.key, action: self.actionSelected.name)
                    self.key = ""
                    self.dataValue = ""
                }
            case .count:
                guard !dataValue.isEmpty else { return }
                let count = transactionDataRepository.count(value: dataValue)
                registerLog(value: dataValue, storedValue: String(describing: count), action: actionSelected.name)
            }
            
            if actionSelected == .set || actionSelected == .delete {
                if !isTransactionActive {
                    if let error = transactionDataRepository.commit() {
                        handleError(error)
                    }
                }
            }
            
            if actionSelected != .delete {
                key = ""
                dataValue = ""
            }
        }
        
        func execute(transactionAction: TransactionActions) {
            switch transactionAction {
            case .begin:
                isTransactionActive = transactionAction == .begin
                registerLog(action: transactionAction.name)
            case .commit:
                showAlert(title: "Are you sure to commit?") { [weak self] in
                    if let error = self?.transactionDataRepository.commit() {
                        self?.handleError(error)
                        return
                    }
                    self?.isTransactionActive = transactionAction == .begin
                    self?.registerLog(action: transactionAction.name)
                }
            case .rollback:
                showAlert(title: "Are you sure to rollback?") { [weak self] in
                    self?.transactionDataRepository.rollback()
                    self?.isTransactionActive = transactionAction == .begin
                    self?.registerLog(action: transactionAction.name)
                }
            }
        }
        
        func hideAlert() {
            isAlertShowed = false
            alertAction = nil
        }
        
        private func showAlert(title: String, action: @escaping AlertAction) {
            alertTitle = title
            isAlertShowed = true
            alertAction = { [weak self] in
                action()
                self?.hideAlert()
            }
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
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

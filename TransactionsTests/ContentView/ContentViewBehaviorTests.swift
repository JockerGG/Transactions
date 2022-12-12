//
//  ContentViewBehaviorTests.swift
//  TransactionsTests
//
//  Created by Eduardo García on 11/12/22.
//

import XCTest
@testable import Transactions

@MainActor final class ContentViewBehaviorTests: XCTestCase {
    private var viewModel: ContentView.ViewModel!
    private var transactionsRepositorySpy: TransactionsRepositorySpy!
    
    @MainActor override func setUp() {
        transactionsRepositorySpy = TransactionsRepositorySpy()
        viewModel = .init(transactionDataRepository: transactionsRepositorySpy)
    }
    
    func test_init_state() {
        XCTAssertEqual(viewModel.actionSelected, .set)
    }
    
    func test_execute_button_enabled() {
        /// Test set state
        viewModel.setAction(.set)
        viewModel.key = "foo"
        XCTAssertFalse(viewModel.executeButtonIsEnabled)
        viewModel.dataValue = "bar"
        XCTAssertTrue(viewModel.executeButtonIsEnabled)
        
        /// Test get state
        viewModel.key = ""
        viewModel.key = ""
        viewModel.setAction(.get)
        XCTAssertFalse(viewModel.executeButtonIsEnabled)
        viewModel.key = "foo"
        XCTAssertTrue(viewModel.executeButtonIsEnabled)
        
        /// Test count state
        viewModel.key = ""
        viewModel.setAction(.count)
        XCTAssertFalse(viewModel.executeButtonIsEnabled)
        viewModel.dataValue = "bar"
        XCTAssertTrue(viewModel.executeButtonIsEnabled)
    }
    
    func test_set_action() {
        viewModel.setAction(.count)
        XCTAssertEqual(viewModel.actionSelected, .count)
        XCTAssertTrue(viewModel.showValueTextField)
        viewModel.setAction(.get)
        XCTAssertEqual(viewModel.actionSelected, .get)
        XCTAssertFalse(viewModel.showValueTextField)
    }
    
    func test_should_enable_transaction_button() {
        XCTAssertTrue(viewModel.shouldEnableTransactionButton(action: .begin))
        viewModel.execute(transactionAction: .begin)
        XCTAssertTrue(viewModel.shouldEnableTransactionButton(action: .commit))
        XCTAssertTrue(viewModel.shouldEnableTransactionButton(action: .rollback))
        viewModel.execute(transactionAction: .rollback)
        /// Simulate the user tap ok on the alert notification.
        viewModel.alertAction?()
        XCTAssertFalse(viewModel.shouldEnableTransactionButton(action: .commit))
        XCTAssertFalse(viewModel.shouldEnableTransactionButton(action: .rollback))
    }
    
    func test_show_alert() {
        viewModel.execute(transactionAction: .commit)
        XCTAssertTrue(viewModel.isAlertShowed)
    }
    
    func test_execute_set_without_transaction_action() throws {
        // Given
        viewModel.setAction(.set)
        viewModel.key = "foo"
        viewModel.dataValue = "bar"
        
        // When
        viewModel.execute()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.setCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.setParameters?.key)
        let value = try XCTUnwrap(transactionsRepositorySpy.setParameters?.value)
        XCTAssertEqual(key, "foo")
        XCTAssertEqual(value, "bar")
        XCTAssertTrue(transactionsRepositorySpy.commitCalled)
    }
    
    func test_execute_set_with_transaction_action_commit() throws {
        // Given
        viewModel.execute(transactionAction: .begin)
        viewModel.setAction(.set)
        viewModel.key = "foo"
        viewModel.dataValue = "bar"
        viewModel.execute()
        
        XCTAssertTrue(transactionsRepositorySpy.setCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.setParameters?.key)
        let value = try XCTUnwrap(transactionsRepositorySpy.setParameters?.value)
        XCTAssertEqual(key, "foo")
        XCTAssertEqual(value, "bar")
        XCTAssertFalse(transactionsRepositorySpy.commitCalled)
        
        // When
        viewModel.execute(transactionAction: .commit)
        viewModel.alertAction?()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.commitCalled)
    }
    
    func test_execute_set_with_transaction_action_rollback() throws {
        // Given
        viewModel.execute(transactionAction: .begin)
        viewModel.setAction(.set)
        viewModel.key = "foo"
        viewModel.dataValue = "bar"
        viewModel.execute()
        
        XCTAssertTrue(transactionsRepositorySpy.setCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.setParameters?.key)
        let value = try XCTUnwrap(transactionsRepositorySpy.setParameters?.value)
        XCTAssertEqual(key, "foo")
        XCTAssertEqual(value, "bar")
        XCTAssertFalse(transactionsRepositorySpy.commitCalled)
        
        // When
        viewModel.execute(transactionAction: .rollback)
        viewModel.alertAction?()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.rollbackCalled)
    }
    
    func test_execute_delete_without_transaction_action() throws {
        // Given
        viewModel.setAction(.delete)
        viewModel.key = "foo"
        
        // When
        viewModel.execute()
        viewModel.alertAction?()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.deleteCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.deleteParameters?.key)
        XCTAssertEqual(key, "foo")
        XCTAssertTrue(transactionsRepositorySpy.commitCalled)
    }
    
    func test_execute_delete_with_transaction_action_commit() throws {
        // Given
        viewModel.execute(transactionAction: .begin)
        viewModel.setAction(.delete)
        viewModel.key = "foo"
        viewModel.execute()
        viewModel.alertAction?()
        
        XCTAssertTrue(transactionsRepositorySpy.deleteCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.deleteParameters?.key)
        XCTAssertEqual(key, "foo")
        XCTAssertFalse(transactionsRepositorySpy.commitCalled)
        
        // When
        viewModel.execute(transactionAction: .commit)
        viewModel.alertAction?()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.commitCalled)
    }
    
    func test_execute_delete_with_transaction_action_rollback() throws {
        // Given
        viewModel.execute(transactionAction: .begin)
        viewModel.setAction(.delete)
        viewModel.key = "foo"
        viewModel.execute()
        viewModel.alertAction?()
        
        XCTAssertTrue(transactionsRepositorySpy.deleteCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.deleteParameters?.key)
        XCTAssertEqual(key, "foo")
        XCTAssertFalse(transactionsRepositorySpy.commitCalled)
        
        // When
        viewModel.execute(transactionAction: .rollback)
        viewModel.alertAction?()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.rollbackCalled)
    }
    
    func test_execute_get() throws {
        // Given
        viewModel.setAction(.get)
        viewModel.key = "foo"
        
        // When
        viewModel.execute()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.getCalled)
        let key = try XCTUnwrap(transactionsRepositorySpy.getParameters?.key)
        XCTAssertEqual(key, "foo")
    }
    
    func test_execute_count() throws {
        // Given
        viewModel.setAction(.count)
        viewModel.dataValue = "bar"
        
        // When
        viewModel.execute()
        
        // Validate
        XCTAssertTrue(transactionsRepositorySpy.countCalled)
        let value = try XCTUnwrap(transactionsRepositorySpy.countParameters?.value)
        XCTAssertEqual(value, "bar")
    }
}

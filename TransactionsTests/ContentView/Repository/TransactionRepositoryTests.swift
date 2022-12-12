//
//  TransactionRepositoryTests.swift
//  TransactionsTests
//
//  Created by Eduardo García on 11/12/22.
//

import XCTest
import CoreData
@testable import Transactions

final class TransactionRepositoryTests: XCTestCase {
    private var context: NSManagedObjectContext!
    private var transactionsRepository: TransactionsDataRepositorable!
    override func setUp() {
        context = TransactionsDataStack().persistenContainer.newBackgroundContext()
        transactionsRepository = TransactionsDataRepository(context: context)
    }
    
    func test_set_values() {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: context)
        transactionsRepository.set(key: "foo", value: "123")
        let error = transactionsRepository.commit()
        XCTAssertNil(error)
        waitForExpectations(timeout: 2.0) { [weak self] error in
            XCTAssertNil(error, "Cannot save changes")
            guard let savedValue = self?.transactionsRepository.get(key: "foo") else {
                XCTFail("Cannot retrieve saved value")
                return
            }
            XCTAssertEqual("foo", savedValue.key)
            XCTAssertEqual("123", savedValue.value)
        }
    }
    
    func test_delete_values() {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: context)
        transactionsRepository.set(key: "foo", value: "123")
        let commitError = transactionsRepository.commit()
        XCTAssertNil(commitError)
        transactionsRepository.delete(key: "foo")
        let deleteError = transactionsRepository.commit()
        XCTAssertNil(deleteError)
        waitForExpectations(timeout: 2.0) { [weak self] error in
            XCTAssertNil(error, "Cannot save changes")
            XCTAssertNil(self?.transactionsRepository.get(key: "foo"), "Delete action is not working as expected")
        }
    }
    
    func test_rollback_values() throws {
        transactionsRepository.set(key: "foo", value: "123")
        let tempValue = transactionsRepository.get(key: "foo")
        XCTAssertNotNil(tempValue)
        let key = try XCTUnwrap(tempValue?.key)
        let value = try XCTUnwrap(tempValue?.value)
        XCTAssertEqual("foo", key)
        XCTAssertEqual("123", value)
        transactionsRepository.rollback()
        XCTAssertNil(transactionsRepository.get(key: "foo"))
    }
}

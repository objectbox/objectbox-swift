//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// swiftlint:disable force_try

import XCTest
@testable import ObjectBox

class ErrorHelperIntegrationTests: XCTestCase {
    func rethrow(_ error: Error) throws {
        throw error
    }
    
    func testStorageException() {
        do {
            _ = try Store(model: createTestModel(), directory: "/dev/DOESNOTEXIST/really/should/fail",
                          maxDbSizeInKByte: 10, fileMode: 0o644, maxReaders: 10)
            XCTFail("Expected exception here.")
        } catch ObjectBoxError.storageGeneral(let message) {
            print("Storage error caught as expected. Message: \"\(message)\"")
            XCTAssert(message.contains("Could not prepare directory"))
            XCTAssert(message.contains("/dev/DOESNOTEXIST/really/should/fail"))
            XCTAssert(message.contains("(2: No such file or directory)"))  // error code
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }
    }
    
    func testDbFullExceptionDuringSetup() {
        let path = StoreHelper.newTemporaryDirectory().path
        do {
            _ = try Store(model: createTestModel(),
                          directory: path,
                          maxDbSizeInKByte: 1,
                          fileMode: 0o644,
                          maxReaders: 10)
            XCTFail("Expected exception here.")
        } catch ObjectBoxError.dbFull(let message) {
            XCTAssert(message == "Could not put")
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }
        
        XCTAssertNoThrow(try FileManager.default.removeItem(atPath: path))
    }
    
    // TODO: This used to be deactivated because of a C++ Bug, see:
    // <https://trello.com/c/VIyCQm3Q/79-fix-testdbfullexception-generating-a-runtime-exception>
    func testDbFullException() {
        let path = StoreHelper.newTemporaryDirectory().path
        do {
            let store = try Store(model: createTestModel(),
                                  directory: path,
                                  maxDbSizeInKByte: 20,
                                  fileMode: 0o644,
                                  maxReaders: 10)
            let box = store.box(for: TestPerson.self)

            var count = 0
            let longName = "".padding(toLength: 100, withPad: "filler text", startingAt: 0)
            while true {
                try box.put(TestPerson(name: longName, age: 1))
                count += 1
            }
        } catch ObjectBoxError.dbFull(let message) {
            // TODO: Extract LMDB error code from this error?
            print("dbFull error caught as expected. \(message)")
            XCTAssert(true)
        } catch {
            XCTAssertNoThrow(try rethrow(error))
        }

        XCTAssertNoThrow(try FileManager.default.removeItem(atPath: path))
    }
    
    static let testTimeout: TimeInterval = 100
    var errorThrownOnThread: Error?
    
    // Recursively creates threads that all simultaneously block in a read transaction.
    // The caller is expected to wait on the iWasClosedExpectation passed in. Once we've created as many threads as
    // requested, or we've received a Swift error thrown telling us we blew the store's maxReaders limit, we fulfill
    // this expectation (each thread fulfills theirs, and waits on that of the additional reader it spawned).
    // Any exception thrown is put in the errorThrownOnThread instance variable of this test.
    @available(iOS 10.0, macOS 10.12, *)
    func createReadersThrow(store: Store, maxReaders num: Int, iWasClosedExpectation: XCTestExpectation) {
        var innerBlockClosedExpectation: XCTestExpectation?
        if num > 1 {
            let block = { innerBlockClosedExpectation = self.expectation(description: "completed block \(num - 1)") }
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.sync(execute: block)
            }
        }
        
        Thread.detachNewThread {
            do {
                try store.runInReadOnlyTransaction { () throws -> Void in
                    if num > 1 {
                        self.createReadersThrow(store: store, maxReaders: num - 1,
                                           iWasClosedExpectation: iWasClosedExpectation)
                    }
                }
            } catch {
                self.errorThrownOnThread = error
                // inner block never got to call this, don't make us wait forever below.
                innerBlockClosedExpectation?.fulfill()
            }
            
            // Don't quit outer readTx before the inner was called to get parallel access
            if let innerBlockClosedExpectation = innerBlockClosedExpectation {
                self.wait(for: [innerBlockClosedExpectation], timeout: ErrorHelperIntegrationTests.testTimeout)
            }
            iWasClosedExpectation.fulfill()
        }
    }
    
    @available(iOS 10.0, macOS 10.12, *)
    func testDbMaxReadersExceptionThrow() {
        // Note: maxReaders doesn't work as expected. mdb_env_setup_locks() applies a minimum based on the rsize to the
        //  maxreaders, so on my Mac, I get 126 even when I request 1. There is also no API to query what it was set to
        //  in ObjectBox yet. So we just create a large number of reader threads and hope things eventually blow up.
        
        let store = try! Store(model: createTestModel(),
                               directory: StoreHelper.newTemporaryDirectory().path,
                               maxDbSizeInKByte: 100,
                               fileMode: 0o644,
                               maxReaders: 1)
        
        let count = 500
        
        errorThrownOnThread = nil
        let outerBlockClosedExpectation = self.expectation(description: "completed block \(count)")
        self.createReadersThrow(store: store, maxReaders: count, iWasClosedExpectation: outerBlockClosedExpectation)
        self.wait(for: [outerBlockClosedExpectation], timeout: ErrorHelperIntegrationTests.testTimeout)
        
        try! store.closeAndDeleteAllFiles()
        
        if let error = errorThrownOnThread, case ObjectBoxError.maxReadersExceeded(let message) = error {
            XCTAssertEqual(message, "Could not begin read transaction (maximum of read transactions reached)")
        } else {
            XCTAssert(false)
        }
    }

    func testSwiftErrorChecker() {
        XCTAssertNoThrow(try ObjectBox.check(error: OBX_SUCCESS, message: "Ignored right now."))
        
        XCTAssertThrowsError(try ObjectBox.check(error: OBX_ERROR_STD_OTHER, message: "Ignored right now."))
    }
    
    func testAppGroupsMissingError() {
        do {
            // This error is reported by `obx_store_open()` when no app group identifier has been set on macOS.
            try throwObxErr(OBX_ERROR_STORAGE_GENERAL, message: "Could not open env for DB (1)")
        } catch ObjectBoxError.storageGeneral(let message) {
            #if os(macOS)
            let testSuccess = message.contains("App Group")
            #else
            let testSuccess = !message.contains("App Group")
            #endif
            if testSuccess {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected exception thrown: storageGeneral(message: \(message))")
            }
        } catch {
            XCTFail("Unexpected exception thrown: \(error)")
        }

        // Any other error should go through unmodified:
        let errMsg = "Could not open env"
        do {
            try throwObxErr(OBX_ERROR_STORAGE_GENERAL, message: errMsg)
        } catch ObjectBoxError.storageGeneral(let message) {
            if message == errMsg {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected exception thrown: storageGeneral(message: \(message))")
            }
        } catch {
            XCTFail("Unexpected exception thrown: \(error)")
        }
    }
}

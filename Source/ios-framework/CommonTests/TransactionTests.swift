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

import XCTest
@testable import ObjectBox

// swiftlint:disable force_try

enum TransactionTestError: Error {
    case exceptionToAbortCommit
}

class TransactionTests: XCTestCase {
    var store: Store!
    
    override func setUp() {
        super.setUp()
        self.store = StoreHelper.tempStore(model: createTestModel())
    }

    override func tearDown() {
        try! store?.closeAndDeleteAllFiles()
        store = nil
        super.tearDown()
    }
    
    func rethrow(_ error: Error) throws {
        throw error
    }

    func testWritability() {
        let writeTx = try! ObjectBox.Transaction(store: store, writable: true)
        let readTx = try! ObjectBox.Transaction(store: store, writable: false)
        
        XCTAssertTrue(writeTx.isWritable)
        XCTAssertFalse(readTx.isWritable)
        
        try! writeTx.close()
        try! readTx.close()
    }
    
    func testFlatBufferReusesObject() {
        let flatBuffer1 = FlatBufferBuilder.dequeue()
        FlatBufferBuilder.return(flatBuffer1)
        let flatBuffer2 = FlatBufferBuilder.dequeue()
        FlatBufferBuilder.return(flatBuffer2)
        XCTAssert(flatBuffer1 === flatBuffer2)
    }
    
    @available(iOS 10.0, macOS 10.12, *)
    func testFlatBuffersAreSeparateOnThreads() {
        var threadDone: Bool = false
        let flatBuffer1 = FlatBufferBuilder.dequeue()
        FlatBufferBuilder.return(flatBuffer1)
        var flatBuffer2: FlatBufferBuilder!
        Thread.detachNewThread {
            flatBuffer2 = FlatBufferBuilder.dequeue()
            FlatBufferBuilder.return(flatBuffer2)
            threadDone = true
        }
        
        while !threadDone {
            usleep(1000)
        }
        
        XCTAssert(flatBuffer1 !== flatBuffer2)
    }
    
    func testTransactionAbortsDontWrite() throws {
        let structBox = store.box(for: StructEntity.self)
        var object = StructEntity(id: 0, message: "Don't write me.", date: Date())
        do {
            try store.runInTransaction {
                try structBox.put(&object)
                throw TransactionTestError.exceptionToAbortCommit
            }
            XCTFail("Expected an exception here.")
        } catch TransactionTestError.exceptionToAbortCommit {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected exception thrown.")
        }
        
        XCTAssertNotEqual(object.id, 0)
        XCTAssertNil(try structBox.get(object.id))
    }
}

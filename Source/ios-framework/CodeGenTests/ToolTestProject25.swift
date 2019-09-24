//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 13.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox
import Foundation

enum Error: Swift.Error {
    case NoIdAssignedToNewlyWrittenEntity
    case ValueReadDoesntEqualValueWritten(property: String, written: Any, read: Any)
    case FailedToReadEntity
}


class TypeTest: Entity {
    var id: EntityId<TypeTest> = 0
    
    var intValue = Int.min
    var int8Value = Int8.min
    var int16Value = Int16.min
    var int32Value = Int32.min
    var int64Value = Int64.min

    var uintValue = UInt.max
    var uint8Value = UInt8.max
    var uint16Value = UInt16.max
    var uint32Value = UInt32.max
    var uint64Value = UInt64.max
    
    var boolValue = true
    var stringValue = "Coming through a cloud you're looking at me from above and I'm a revelation spreading out before your eyes."
    var byteValue: Byte = Byte.min
    var bytes: Data = "🤪🥶💃".data(using: .utf8)!
    var byteArray: Data = "🇮🇹🇷🇺🇬🇧🇩🇪🇨🇭🇺🇸".data(using: .utf8)!
    var floatValue: Float = -13762.6
    var doubleValue: Double = -15301.06221
    var dateValue: Date = Date(timeIntervalSinceReferenceDate: 900.75)

    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let originalTypeTest = TypeTest()

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB25/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let typeTestBox = store.box(for: TypeTest.self)
    
    let newId = try typeTestBox.put(originalTypeTest)
    if (newId.value == 0) {
        throw Error.NoIdAssignedToNewlyWrittenEntity
    }
    
    if let readTypeTest = try typeTestBox.get(newId) {
        if (originalTypeTest.intValue != readTypeTest.intValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "int", written: originalTypeTest.intValue, read: readTypeTest.intValue)
        }
        if (originalTypeTest.int8Value != readTypeTest.int8Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "int8", written: originalTypeTest.int8Value, read: readTypeTest.int8Value)
        }
        if (originalTypeTest.int16Value != readTypeTest.int16Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "int16", written: originalTypeTest.int16Value, read: readTypeTest.int16Value)
        }
        if (originalTypeTest.int32Value != readTypeTest.int32Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "int32", written: originalTypeTest.int32Value, read: readTypeTest.int32Value)
        }
        if (originalTypeTest.int64Value != readTypeTest.int64Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "int64", written: originalTypeTest.int64Value, read: readTypeTest.int64Value)
        }
        if (originalTypeTest.uintValue != readTypeTest.uintValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "uint", written: originalTypeTest.uintValue, read: readTypeTest.uintValue)
        }
        if (originalTypeTest.uint8Value != readTypeTest.uint8Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "uint8", written: originalTypeTest.uint8Value, read: readTypeTest.uint8Value)
        }
        if (originalTypeTest.uint16Value != readTypeTest.uint16Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "uint16", written: originalTypeTest.uint16Value, read: readTypeTest.uint16Value)
        }
        if (originalTypeTest.uint32Value != readTypeTest.uint32Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "uint32", written: originalTypeTest.uint32Value, read: readTypeTest.uint32Value)
        }
        if (originalTypeTest.uint64Value != readTypeTest.uint64Value) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "uint64", written: originalTypeTest.uint64Value, read: readTypeTest.uint64Value)
        }
        if (originalTypeTest.boolValue != readTypeTest.boolValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "bool", written: originalTypeTest.boolValue, read: readTypeTest.boolValue)
        }
        if (originalTypeTest.stringValue != readTypeTest.stringValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "string", written: originalTypeTest.stringValue, read: readTypeTest.stringValue)
        }
        if (originalTypeTest.byteValue != readTypeTest.byteValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "byte", written: originalTypeTest.byteValue, read: readTypeTest.byteValue)
        }
        let originalString = String(data: originalTypeTest.bytes, encoding: .utf8)!
        let readString = String(data: readTypeTest.bytes, encoding: .utf8)!
        if (originalString != readString) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "bytes", written: originalString, read: readString)
        }
        let originalString2 = "\(originalTypeTest.byteArray)"
        let readString2 = "\(readTypeTest.byteArray)"
        if (originalString2 != readString2) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "byteArray", written: originalString2, read: readString2)
        }
        if (originalTypeTest.floatValue != readTypeTest.floatValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "float", written: originalTypeTest.floatValue, read: readTypeTest.floatValue)
        }
        if (originalTypeTest.doubleValue != readTypeTest.doubleValue) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "double", written: originalTypeTest.doubleValue, read: readTypeTest.doubleValue)
        }
        if ((originalTypeTest.dateValue.timeIntervalSinceReferenceDate - readTypeTest.dateValue.timeIntervalSinceReferenceDate) > 0.001) {
            throw Error.ValueReadDoesntEqualValueWritten(property: "date", written: originalTypeTest.dateValue, read: readTypeTest.dateValue)
        }
    } else {
        throw Error.FailedToReadEntity
    }

    return 0
}

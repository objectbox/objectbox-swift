//
// Copyright © 2018 ObjectBox Ltd. All rights reserved.
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

import Foundation

extension Array where Element: LongPropertyQueryType {
    fileprivate var int64s: [Int64] { return self.map { $0.int64Value } }
}

extension Array where Element: IntegerPropertyQueryType {
    fileprivate var int64s: [Int64] { return self.map { Int64($0.int32Value) } }
}

// MARK: - Integer types

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<T>(_ property: Property<EntityType, T, Void>, to value: T) where T: FixedWidthInteger {
        setParameterInternal(property: property.base, to: Int64(truncatingIfNeeded: value))
    }

    /// :nodoc:
    public func setParameter<T>(_ property: Property<EntityType, T?, Void>, to value: T) where T: FixedWidthInteger {
        setParameterInternal(property: property.base, to: Int64(truncatingIfNeeded: value))
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter<T>(_ alias: String, to value: T) where T: FixedWidthInteger {
        setParameterInternal(alias, to: Int64(truncatingIfNeeded: value))
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(_:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters<T>(_ property: Property<EntityType, T, Void>, to value1: T, _ value2: T)
            where T: FixedWidthInteger {
        setParametersInternal(property: property.base, to: Int64(truncatingIfNeeded: value1),
                Int64(truncatingIfNeeded: value2))
    }

    /// :nodoc:
    public func setParameters<T>(_ property: Property<EntityType, T?, Void>, to value1: T, _ value2: T)
            where T: FixedWidthInteger {
        setParametersInternal(property: property.base, to: Int64(truncatingIfNeeded: value1),
                Int64(truncatingIfNeeded: value2))
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    /// See `setParameter(_:to:)` for operators with 1 value.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters<T>(_ alias: String, to value1: T, _ value2: T) where T: FixedWidthInteger {
        setParametersInternal(alias, to: Int64(value1), Int64(truncatingIfNeeded: value2))
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// Note: While there is some flexibility for the passed type, you must ensure that the actual values are within
    ///       the valid range. E.g. passing in a integer beyond 32 bit for a 32 bit parameter type is a usage error and
    ///       will result in a fatal error.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - collection: New collection of values for the condition.
    public func setParameters<T>(_ property: Property<EntityType, T, Void>, to collection: [T])
            where T: FixedWidthInteger {
        setParametersInternal(property: property.base, to: collection)
    }

    /// :nodoc:
    public func setParameters<T>(_ property: Property<EntityType, T?, Void>, to collection: [T])
            where T: FixedWidthInteger {
        setParametersInternal(property: property.base, to: collection)
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// Note: While there is some flexibility for the passed type, you must ensure that the actual values are within
    ///       the valid range. E.g. passing in a integer beyond 32 bit for a 32 bit parameter type is a usage error and
    ///       will result in a fatal error.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters<T>(_ alias: String, to collection: [T]) where T: FixedWidthInteger {
        let typeSize = obx_query_param_alias_get_type_size(cQuery, alias)
        if typeSize == 8 {
            setParametersInternal(alias, to: Util.toInt64Array(collection))
        } else {
            precondition(typeSize > 0 && typeSize <= 4)
            let collection32: [Int32]
            do {
                collection32 = try Util.toInt32Array(collection)
            } catch {
                fatalErrorWithStack("Usage error; ensure to use the proper parameter type (alias: \(alias)): \(error)")
            }
            setParametersInternal(alias, to: collection32)
        }
    }
}

// MARK: - Bool
extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==`.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, Bool, Void>, to value: Bool) {
        setParameterInternal(property: property.base, to: Int64(value ? 1 : 0))
    }

    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, Bool?, Void>, to value: Bool) {
        setParameterInternal(property: property.base, to: Int64(value ? 1 : 0))
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter(_ alias: String, to value: Bool) {
        setParameter(alias, to: value ? 1 : 0)
    }

}

// MARK: - Floating point

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==` or `isGreaterThan`/`>`
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<T>(_ property: Property<EntityType, T, Void>, to value: T) where T: BinaryFloatingPoint {
        setParameterInternal(property: property.base, to: Double(value))
    }

    /// :nodoc:
    public func setParameter<T>(_ property: Property<EntityType, T?, Void>, to value: T) where T: BinaryFloatingPoint {
        setParameterInternal(property: property.base, to: Double(value))
    }

    /// Convenience for `setParameters(property:to:_:)` that offers the same API as a floating point
    /// equality condition with a tolerance.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change and use `setParameter(_:toEqual:tolerance:).
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: Value to compare, ± `tolerance`.
    ///   - tolerance: Tolerance around `value`.
    public func setParameter<T>(_ property: Property<EntityType, T, Void>, toEqual value: T, tolerance: T)
            where T: BinaryFloatingPoint {
        self.setParameters(property, to: value - tolerance, value + tolerance)
    }

    /// :nodoc:
    public func setParameter<T>(_ property: Property<EntityType, T?, Void>, toEqual value: T, tolerance: T)
            where T: BinaryFloatingPoint {
        self.setParameters(property, to: value - tolerance, value + tolerance)
    }

    /// Convenience for `setParameters(_:to:_:)` that offers the same API as a floating point equality
    /// condition with a tolerance.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: Value to compare, ± `tolerance`.
    ///   - tolerance: Tolerance around `value`.
    public func setParameters<T>(_ alias: String, toEqual value: T, tolerance: T) where T: BinaryFloatingPoint {
        setParameters(alias, to: value - tolerance, value + tolerance)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    internal func setParameter<T>(_ alias: String, to value: T) where T: BinaryFloatingPoint {
        setParameterInternal(alias, to: Double(value))
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    /// See `setParameter(alias:to:)` for operators with 1 value.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    internal func setParameters<T>(_ alias: String, to value1: T, _ value2: T) where T: BinaryFloatingPoint {
        setParametersInternal(alias, to: Double(value1), Double(value2))
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(_:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters<T>(_ property: Property<EntityType, T, Void>, to value1: T, _ value2: T)
            where T: BinaryFloatingPoint {
        setParametersInternal(property: property.base, to: Double(value1), Double(value2))
    }

    /// :nodoc:
    public func setParameters<T>(_ property: Property<EntityType, T?, Void>, to value1: T, _ value2: T)
            where T: BinaryFloatingPoint {
        setParametersInternal(property: property.base, to: Double(value1), Double(value2))
    }
}

// MARK: - String

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==` or `isGreaterThan`/`>`
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, String, Void>, to string: String) {
        setParameterInternal(property: property.base, to: string)
    }

    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, String?, Void>, to string: String) {
        setParameterInternal(property: property.base, to: string)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - collection: New collection of values for the condition.
    public func setParameters(_ property: Property<EntityType, String, Void>, to collection: [String]) {
        setParametersInternal(property: property.base, to: collection)
    }

    /// :nodoc:
    public func setParameters(_ property: Property<EntityType, String?, Void>, to collection: [String]) {
        setParametersInternal(property: property.base, to: collection)
    }
}

// MARK: - Date

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==` or `isGreaterThan`/`>`
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, Date, Void>, to value: Date) {
        setParameterInternal(property: property.base, to: value.unixTimestamp)
    }

    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, Date?, Void>, to value: Date) {
        setParameterInternal(property: property.base, to: value.unixTimestamp)
    }

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the variant for conditions taking single parameter e.g. `isEqual`/`==` or `isGreaterThan`/`>`
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value for the condition.
    public func setParameter(_ alias: String, to value: Date) {
        setParameterInternal(alias, to: value.unixTimestamp)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - collection: New collection of values for the condition.
    public func setParameters(_ property: Property<EntityType, Date, Void>, to collection: [Date]) {
        let collection64 = collection.map({ $0.unixTimestamp })
        setParametersInternal64(property: property.base, to: collection64)
    }

    /// :nodoc:
    public func setParameters(_ property: Property<EntityType, Date?, Void>, to collection: [Date]) {
        let collection64 = collection.map({ $0.unixTimestamp })
        setParametersInternal64(property: property.base, to: collection64)
    }

    /// :nodoc:
    public func setParameters(_ alias: String, to collection: [Date]) {
        let collection64 = collection.map({ $0.unixTimestamp })
        setParametersInternal(alias, to: collection64)
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(_:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters(_ property: Property<EntityType, Date, Void>, to value1: Date, _ value2: Date) {
        setParametersInternal(property: property.base, to: value1.unixTimestamp, value2.unixTimestamp)
    }

    /// :nodoc:
    public func setParameters(_ property: Property<EntityType, Date?, Void>, to value1: Date, _ value2: Date) {
        setParametersInternal(property: property.base, to: value1.unixTimestamp, value2.unixTimestamp)
    }

    /// :nodoc:
    public func setParameters(_ alias: String, to value1: Date, _ value2: Date) {
        setParametersInternal(alias, to: value1.unixTimestamp, value2.unixTimestamp)
    }

}

// MARK: - Data

extension Query {
    internal func setParameterInternal(_ property: PropertyDescriptor, to value: Data) {
        let bufferLength = value.count
        value.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> Void in
            let err = obx_query_param_bytes(cQuery, EntityType.entityInfo.entitySchemaId, property.propertyId,
                    buffer.baseAddress, bufferLength)
            checkFatalErrorParam(err)
        })
    }


    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, Data, Void>, to value: Data) {
        setParameterInternal(property.base, to: value)
    }

    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, Data?, Void>, to value: Data) {
        setParameterInternal(property.base, to: value)
    }

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value for the condition.
    public func setParameter(_ alias: String, to value: Data) {
        let bufferLength = value.count
        value.withUnsafeBytes({ (buffer: UnsafeRawBufferPointer) -> Void in
            let err = obx_query_param_alias_bytes(cQuery, alias, buffer.baseAddress, bufferLength)
            checkFatalErrorParam(err)
        })
    }
}

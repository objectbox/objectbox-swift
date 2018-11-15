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

extension Array where Element: LongPropertyQueryType {
    fileprivate var nsNumbers: [NSNumber] { return self.map { $0.int64Value } as [NSNumber] }
}

extension Array where Element: IntegerPropertyQueryType {
    fileprivate var nsNumbers: [NSNumber] { return self.map { $0.int32Value } as [NSNumber] }
}

// MARK: - Integer types

extension Query {

    // MARK: Int64

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(property:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<L>(property: Property<EntityType, L>, to value: L) where L: LongPropertyQueryType {
        base.setParameter(property: property.base, to: value.int64Value)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter<L>(alias: String, to value: L) where L: LongPropertyQueryType {
        base.setParameter(alias: alias, to: value.int64Value)
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(property:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters<L>(property: Property<EntityType, L>, to value1: L, _ value2: L)
        where L: LongPropertyQueryType {
        base.setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<L>(alias: String, to value1: L, _ value2: L) where L: LongPropertyQueryType {
        base.setParameters(alias: alias, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<L>(property: Property<EntityType, L>, to collection: [L]) where L: LongPropertyQueryType {
        base.setParameters(property: property.base, to: collection.nsNumbers )
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters<L>(alias: String, to collection: [L]) where L: LongPropertyQueryType {
        let longs = collection.map { $0.int64Value }
        longs.withUnsafeBufferPointer { bufPtr -> Void in
            guard let pointer = bufPtr.baseAddress else { return }
            base.setParametersForPropertyWithAlias(alias, longs: pointer, length: UInt64(bufPtr.count))
        }
    }

    // MARK: Int32

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(property:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<I>(property: Property<EntityType, I>, to value: I)
        where I: IntegerPropertyQueryType {
        base.setParameter(property: property.base, to: value.int64Value)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter<I>(alias: String, to value: I) where I: IntegerPropertyQueryType {
        base.setParameter(alias: alias, to: value.int64Value)
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(property:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters<I>(property: Property<EntityType, I>, to value1: I, _ value2: I)
        where I: IntegerPropertyQueryType {
            base.setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<I>(alias: String, to value1: I, _ value2: I)
        where I: IntegerPropertyQueryType {
        base.setParameters(alias: alias, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<I>(property: Property<EntityType, I>, to collection: [I])
        where I: IntegerPropertyQueryType {
        base.setParameters(property: property.base, to: collection.nsNumbers )
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters<I>(alias: String, to collection: [I])
        where I: IntegerPropertyQueryType {
        let ints = collection.map { $0.int32Value }
        ints.withUnsafeBufferPointer { bufPtr -> Void in
            guard let pointer = bufPtr.baseAddress else { return }
            base.setParametersForPropertyWithAlias(alias, ints: pointer, length: UInt64(bufPtr.count))
        }
    }
}

// MARK: - Double

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(property:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(property: Property<EntityType, Double>, to value: Double) {
        base.setParameter(property: property.base, to: value)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter(alias: String, to value: Double) {
        base.setParameter(alias: alias, to: value)
    }

    /// Convenience for `setParameters(property:to:_:)` that offers the same API as a floating point
    /// equality condition with a tolerance.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change and use `setParameter(alias:toEqual:tolerance:).
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: Value to compare, ± `tolerance`.
    ///   - tolerance: Tolerance around `value`.
    public func setParameter(property: Property<EntityType, Double>, toEqual value: Double, tolerance: Double) {
        self.setParameters(property: property, to: (value - tolerance), (value + tolerance))
    }

    /// Convenience for `setParameters(alias:to:_:)` that offers the same API as a floating point equality
    /// condition with a tolerance.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: Value to compare, ± `tolerance`.
    ///   - tolerance: Tolerance around `value`.
    public func setParameters(alias: String, toEqual value: Double, tolerance: Double) {
        base.setParameters(alias: alias, to: (value - tolerance), (value + tolerance))
    }

    /// Sets a parameter of a condition previously specified during query construction to new values.
    ///
    /// This is the variant with 2 values, e.g. for `isBetween(_:and:)` comparison.
    ///
    /// See `setParameter(property:to:)` for operators with 1 value.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value1: New first value for the condition.
    ///   - value2: New second value for the condition.
    public func setParameters(property: Property<EntityType, Double>, to value1: Double, _ value2: Double) {
        base.setParameters(property: property.base, to: value1, value2)
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
    public func setParameters(alias: String, to value1: Double, _ value2: Double) {
        base.setParameters(alias: alias, to: value1, value2)
    }
}

// MARK: - String

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(property:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(property: Property<EntityType, String>, to string: String) {
        base.setParameter(property: property.base, to: string)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(alias:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter(alias: String, to string: String) {
        base.setParameter(alias: alias, to: string)
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
    public func setParameters(property: Property<EntityType, String>, to collection: [String]) {
        base.setParameters(property: property.base, to: collection)
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters(alias: String, to collection: [String]) {
        base.setParameters(alias: alias, to: collection)
    }
}

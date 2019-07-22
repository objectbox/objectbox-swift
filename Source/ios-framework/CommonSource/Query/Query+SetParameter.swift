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
    fileprivate var int64s: [Int64] { return self.map { $0.int64Value } }
}

extension Array where Element: IntegerPropertyQueryType {
    fileprivate var int64s: [Int64] { return self.map { Int64($0.int32Value) } }
}

// MARK: - Integer types

extension Query {

    // MARK: Int64

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<L>(_ property: Property<EntityType, L>, to value: L) where L: LongPropertyQueryType {
        setParameter(property: property.base, to: value.int64Value)
    }

    /// :nodoc:
    public func setParameter<L>(_ property: Property<EntityType, L?>, to value: L) where L: LongPropertyQueryType {
        setParameter(property: property.base, to: value.int64Value)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter<L>(_ alias: String, to value: L) where L: LongPropertyQueryType {
        setParameter(alias, to: value.int64Value)
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
    public func setParameters<L>(_ property: Property<EntityType, L>, to value1: L, _ value2: L)
        where L: LongPropertyQueryType {
        setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
    }

    /// :nodoc:
    public func setParameters<L>(_ property: Property<EntityType, L?>, to value1: L, _ value2: L)
        where L: LongPropertyQueryType {
            setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<L>(_ alias: String, to value1: L, _ value2: L) where L: LongPropertyQueryType {
        setParameters(alias, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<L>(_ property: Property<EntityType, L>, to collection: [L])
        where L: LongPropertyQueryType {
        setParameters(property: property.base, to: collection.int64s )
    }

    /// :nodoc:
    public func setParameters<L>(_ property: Property<EntityType, L?>, to collection: [L])
        where L: LongPropertyQueryType {
        setParameters(property: property.base, to: collection.int64s )
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters<L>(_ alias: String, to collection: [L]) where L: LongPropertyQueryType {
        let longs = collection.map { $0.int64Value }
        setParametersForPropertyWithAlias(alias, to: longs)
    }

    // MARK: Int32

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter<I>(_ property: Property<EntityType, I>, to value: I)
        where I: IntegerPropertyQueryType {
        setParameter(property: property.base, to: value.int64Value)
    }

    /// :nodoc:
    public func setParameter<I>(_ property: Property<EntityType, I?>, to value: I)
        where I: IntegerPropertyQueryType {
            setParameter(property: property.base, to: value.int64Value)
    }

    /// Sets a parameter previously specified using a `ParameterAlias` to a new value.
    ///
    /// This is the binary operator variant. See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: New value.
    public func setParameter<I>(_ alias: String, to value: I) where I: IntegerPropertyQueryType {
        setParameter(alias, to: value.int64Value)
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
    public func setParameters<I>(_ property: Property<EntityType, I>, to value1: I, _ value2: I)
        where I: IntegerPropertyQueryType {
            setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
    }

    /// :nodoc:
    public func setParameters<I>(_ property: Property<EntityType, I?>, to value1: I, _ value2: I)
        where I: IntegerPropertyQueryType {
            setParameters(property: property.base, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<I>(_ alias: String, to value1: I, _ value2: I)
        where I: IntegerPropertyQueryType {
        setParameters(alias, to: value1.int64Value, value2.int64Value)
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
    public func setParameters<I>(_ property: Property<EntityType, I>, to collection: [I])
        where I: IntegerPropertyQueryType {
        setParameters(property: property.base, to: collection.int64s )
    }

    /// :nodoc:
    public func setParameters<I>(_ property: Property<EntityType, I?>, to collection: [I])
        where I: IntegerPropertyQueryType {
            setParameters(property: property.base, to: collection.int64s )
    }

    /// Sets a parameter previously specified during query construction to a new collection value.
    ///
    /// This is used to change the value of e.g. `isContained(in:)` and similar operations.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - collection: New collection of values for the condition.
    public func setParameters<I>(_ alias: String, to collection: [I])
        where I: IntegerPropertyQueryType {
        let ints = collection.map { $0.int32Value }
        setParametersForPropertyWithAlias(alias, to: ints)
    }
}

// MARK: - Double

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, Double>, to value: Double) {
        setParameter(property: property.base, to: value)
    }
    
    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, Double?>, to value: Double) {
        setParameter(property: property.base, to: value)
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
    public func setParameter(_ property: Property<EntityType, Double>, toEqual value: Double, tolerance: Double) {
        self.setParameters(property, to: (value - tolerance), (value + tolerance))
    }
    
    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, Double?>, toEqual value: Double, tolerance: Double) {
        self.setParameters(property, to: (value - tolerance), (value + tolerance))
    }
    
    /// Convenience for `setParameters(_:to:_:)` that offers the same API as a floating point equality
    /// condition with a tolerance.
    ///
    /// - Parameters:
    ///   - alias: Condition's alias.
    ///   - value: Value to compare, ± `tolerance`.
    ///   - tolerance: Tolerance around `value`.
    public func setParameters(_ alias: String, toEqual value: Double, tolerance: Double) {
        setParameters(alias, to: (value - tolerance), (value + tolerance))
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
    public func setParameters(_ property: Property<EntityType, Double>, to value1: Double, _ value2: Double) {
        setParameters(property: property.base, to: value1, value2)
    }
    
    /// :nodoc:
    public func setParameters(_ property: Property<EntityType, Double?>, to value1: Double, _ value2: Double) {
        setParameters(property: property.base, to: value1, value2)
    }
}

// MARK: - String

extension Query {

    /// Sets a parameter of a condition previously specified during query construction to a new value.
    ///
    /// This is the binary operator variant. It changes the value no matter which operation you used,
    /// e.g. `isEqual`/`==` or `isGreaterThan`/`>`.
    ///
    /// See `setParameters(_:to:_:)` for operators with 2 values.
    ///
    /// If you have multiple conditions on the same property, specify a `PropertyAlias` so you can choose which
    /// condition's value to change.
    ///
    /// - Parameters:
    ///   - property: Entity property specification.
    ///   - value: New value for the condition.
    public func setParameter(_ property: Property<EntityType, String>, to string: String) {
        setParameter(property: property.base, to: string)
    }
    
    /// :nodoc:
    public func setParameter(_ property: Property<EntityType, String?>, to string: String) {
        setParameter(property: property.base, to: string)
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
    public func setParameters(_ property: Property<EntityType, String>, to collection: [String]) {
        setParameters(property: property.base, to: collection)
    }
    
    /// :nodoc:
    public func setParameters(_ property: Property<EntityType, String?>, to collection: [String]) {
        setParameters(property: property.base, to: collection)
    }
}

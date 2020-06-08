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

/// As a convenience, you can register a short name (called an _alias_) for a query condition,
/// and later modify its values.
///
/// Example of the operator in the block-based syntax:
///
///     let query1 = try personBox.query { "AgeRestriction" .= Person.age > 21 }.build()
///     let query2 = try personBox.query { "AgeRestriction" .= Person.age > 18 }.build()
///     try query1.setParameter("AgeRestriction", to: 18)
///     // Now query1 and query2 produce the same results
///
/// Currently, aliases do not work for non-block-based queries.
///
/// - Note: `setParameter` does not perform type checks for you. Do not use a String variant for an integer parameter.
public class PropertyAlias<E: EntityInspectable & __EntityRelatable, T: EntityPropertyTypeConvertible>:
    QueryCondition<E>
where E == E.EntityBindingType.EntityType {
    /// Entity type that contains the property this query is aliasing.
    public typealias EntityType = E
    
    /// Supported property value type this alias is describing.
    public typealias ValueType = T
    
    internal let condition: PropertyQueryCondition<EntityType, ValueType>
    
    /// The short name.
    public let alias: String
    
    internal init(condition: PropertyQueryCondition<EntityType, ValueType>, alias: String) {
        self.condition = condition
        self.alias = alias
        super.init(expression: condition.expression)
    }
    
    override func evaluate(queryBuilder: QueryBuilder<E>) -> QueryBuilderCondition {
        condition.alias = self.alias
        return QueryBuilderCondition(condition.evaluate(queryBuilder: queryBuilder).cCondition,
                                     builder: queryBuilder.queryBuilder)
    }
}

precedencegroup PropertyAliasPrecedence {
    higherThan: LogicalConjunctionPrecedence, LogicalDisjunctionPrecedence
    lowerThan: ComparisonPrecedence
    associativity: none
    assignment: true
}

infix operator .= : PropertyAliasPrecedence

/// This operator is used in Box.query()'s block to define a named alias for a query.
///
/// - Parameters:
///   - alias: The short name for `condition`.
///   - condition: The condition the short name should be applied to.
/// - Returns: An object representing the short name/condition association that you can return from the block.
public func .= <E, T>(alias: String, condition: PropertyQueryCondition<E, T>) -> PropertyAlias<E, T> {
    return PropertyAlias(condition: condition, alias: alias)
}

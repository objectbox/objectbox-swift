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

// MARK: - Query Creation

extension Box {

    /// Create a blank QueryBuilder you can configure afterwards.
    ///
    /// - Returns: QueryBuilder for a blank query.
    public func query() -> QueryBuilder<EntityType> {
        do {
            let queryBuilder = try QueryBuilder<EntityType>(store: store)
            return queryBuilder
        } catch {
            fatalError("Unexpected error \(error) creating an empty query.")
        }
    }

    /// Create a QueryBuilder for a query with initial conditions expressed inside the block.
    ///
    /// To create an object of the expected return type `QueryCondition`, you can use comparison operators
    /// on the `Property` metadata object of your entity. Combine multiple conditions with boolean operators.
    /// See the type declaration of `Property` for a list of methods.
    ///
    /// Example:
    ///
    ///     class Person: Entity {
    ///         var name: String
    ///         var age: Int
    ///
    ///         // Code generator creates:
    ///         //
    ///         //     static var name: Property<Person, String>
    ///         //     static var age: Property<Person, Int>
    ///     }
    ///
    ///     let personBox: Box<Person>
    ///     let query = personBox.query { Person.name.startsWith("M") && Person.age >= 18 }
    ///
    /// Operators you might be interested in:
    ///
    /// - Boolean: `&&` and `||`
    /// - Containment: `∈` and `∉`
    /// - Equality: `==` and `!=`
    /// - Comparison: `<` and `>`
    ///
    /// Number-based properties also offer methods like `isBetween`, while String-based properties offer
    /// `startsWith` and `contains`.
    ///
    /// The list of supported operations for each `Property<EntityType, ValueType>` depends on the `ValueType`;
    /// you can explore Xcode's auto-completion or refer to our guide at <https://objectbox.io>.
    ///
    /// Call `build()` on the `QueryBuilder` to obtain a `Query` that you can actually run or whose placeholder
    /// values you can modify.
    public func query(_ conditions: () -> QueryCondition<EntityType>) -> QueryBuilder<EntityType> {
        do {
            let queryBuilder = try QueryBuilder<EntityType>(store: store)
            let expression = conditions()
            _ = expression.evaluate(queryBuilder: queryBuilder)
            return queryBuilder
        } catch {
            fatalError("Unexpected error creating query: \(error)")
        }
    }
}

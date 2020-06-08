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

    /// Create a blank QueryBuilder you can configure afterwards. This is useful if you don't want to filter but still
    /// want to perform a link (join) or control the order of results.
    ///
    /// Call `build()` on the `QueryBuilder` to obtain a `Query` that you can actually run or whose placeholder
    /// values you can modify.
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

    /// Return a QueryBuilder that can be used to create a Query with conditions expressed inside a block.
    ///
    /// Example:
    ///
    ///     let personBox: Box<Person> = store.box()
    ///     let query = personBox.query { Person.name.startsWith("M") && Person.age >= 18 }.build()
    ///
    /// The list of supported operators and methods for each property depends on its type. Number-based properties offer
    /// methods like `isBetween`, while String-based properties offer `startsWith`, `contains` etc.
    ///
    /// You can explore Xcode's auto-completion or refer to our documentation at <https://swift.objectbox.io>.
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

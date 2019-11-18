# Query Syntax

ObjectBox lets you formulate your database search queries as familiar-looking Swift expressions. Please [refer to the guides](https://swift.objectbox.io/queries) for a general introduction. This document is a short syntax reference.

## `Property`-Based

Inside `Box.query(_:)`, you can use the generated `Property` objects to form query conditions:

```swift
// Written by you:
class Person: Entity {
    var name: String
    // ...
}

// Created by the code generator with the same names as 
// your entity properties:
extension Person {
    static var name: Property<Person, String> { /* ... */ }
}

// Then you can write:
try store.box(for: Person.self).query {
    Person.name.isEqual(to: "Steve", caseSensitiveCompare: true)
}.build()
```

or more succinctly,

```swift
try store.box(for: Person.self).query {
    .name == "Steve"
}.build()
```

A variety of conditions are available for your use in query expressions, depending on the type of the
`Property.ValueType` (`String` in the example above). For example:

- `Property.isEqual(to:)`
- `Property.isNotEqual(to:)`
- `Property.isGreaterThan(_:)`
- `Property.isBetween(_:and:)`

Please refer to the API docs of `Property` for a complete list.

## Operators

To make queries more familiar and readable, you can also use standard Swift operators in
query blocks. Under the hood, these operators produce `QueryCondition`s as their results,
so are 100% equivalent.

Currently, supported operators are:

- `==` for `Property.isEqual(to:)`
- `!=` for `Property.isNotEqual(to:)`
- `<` for `Property.isLessThan(_:)` or `Property.isBefore(_:)`
- `>` for `Property.isGreaterThan(_:)` or `Property.isAfter(_:)`
- `∈` for `Property.isIn(_:)`
- `∉` for `Property.isNotIn(_:)`

Note that not all operators are available for every `Property.ValueType`.

In addition to these conditional operators, there is the `.=` operator to create `PropertyAlias`es.

```swift
try store.box(for: Person.self).query {
    return "AgeRestriction" .= Person.age > 18
        && Person.name.startsWith("St")
}.build()
```

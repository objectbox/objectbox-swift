# Changelog

Notable changes to the ObjectBox Swift library.

For more insights into what changed in the ObjectBox C++ core, [check the ObjectBox C changelog](https://github.com/objectbox/objectbox-c/blob/main/CHANGELOG.md).
              
## 5.0.0 - 2025-09-29

- Update ObjectBox database to version `5.0.0-2025-09-27`.
  - ToOne relations: when deleting an object with an ID larger than the maximum 32-bit unsigned integer 
    (`4294967295`) that is used as the target object of a ToOne, correctly re-set the target ID of the ToOne to
    `0`. [objectbox-dart#740](https://github.com/objectbox/objectbox-dart/issues/740) 

### Sync

- Support Sync server version 5.0.
    - **User-Specific Data Sync**: support configuring [Sync filter](https://sync.objectbox.io/sync-server/sync-filters)
      variables on `SyncClient`.

## 4.4.1 - 2025-09-01

- Update ObjectBox database to version `4.3.1-2025-08-02`.
- The Swift plugin accepts arguments for the generator, like `--visiblity public`. [#101](https://github.com/objectbox/objectbox-swift/issues/101)
- The generator Swift plugin asks for the network permission to send anonymous statistics. Pass the
  `--no-statistics` argument to not send them.

## 4.4.0 - 2025-07-09

- **Breaking API change: when using the Swift Package, make sure to run the generator again.**
  For Xcode projects, right-click your project in the Project navigator and click ObjectBoxGeneratorCommand.
  For Swift Package projects, run `swift package plugin --allow-writing-to-package-directory objectbox-generator`.  
  When using ObjectBox through CocoaPods the generated code is updated when next building your project.
- Change generated code to support Swift 6 language mode [#91](https://github.com/objectbox/objectbox-swift/issues/91)
- When using ObjectBox through CocoaPods, support Xcode 16 projects that use groups as well as buildable folders

## 4.3.0 - 2025-05-21

- Update ObjectBox database to version `4.3.0-2025-05-12`.
- The generator supports Xcode 16 projects with buildable folders. [#94](https://github.com/objectbox/objectbox-swift/issues/94)
- External property types and names (via [MongoDB connector Data Mapping](https://sync.objectbox.io/mongodb-sync-connector/mongodb-data-mapping))

### Sync

- Add "Log Events" for important server events, which can be viewed on a new Admin page.
- Detect and ignore changes for objects that were put but were unchanged.
- The limit for message size was raised to 32 MB.
- Transactions above the message size limit now already fail on the client (to better enforce the limit).

## 4.2.0 - 2025-04-09

- Vector Search: add new `geo` distance type to perform vector searches on geographical coordinates.
  This is particularly useful for location-based applications.
- Make `Store.close()` public. This function may be useful for when the deinitializer of `Store` is called too late
  (which closes the Store as well), or for unit tests.
- Update ObjectBox database to [4.2.0](https://github.com/objectbox/objectbox-c/releases/tag/v4.2.0).

## 4.0.1 - 2024-10-16

- Built with Xcode 15.0.1 and Swift 5.9.
- Make closing the Store more robust. In addition to transactions, it also waits for ongoing queries. This is just an
  additional safety net. Your apps should still make sure to finish all Store operations, like queries, before closing it.
- Generator: no longer print a `Mapping not found` warning when an entity class uses `ToMany`.
- Some minor vector search performance improvements.
- Update to [ObjectBox C 4.0.2](https://github.com/objectbox/objectbox-c/releases/tag/v4.0.2).

### Sync

- **Fix a serious regression, please update as soon as possible.**

## 4.0.0 - 2024-07-22

**ObjectBox now supports [Vector Search](https://docs.objectbox.io/ann-vector-search)** to enable efficient similarity searches.

This is particularly useful for AI/ML/RAG applications, e.g. image, audio, or text similarity. Other use cases include semantic search or recommendation engines.

Create a Vector (HNSW) index for a floating point vector property. For example, a `City` with a location vector:

```swift
// objectbox: entity
class City {

    // objectbox:hnswIndex: dimensions=2
    var location: [Float]?
    
}
```

Perform a nearest neighbor search using the new `nearestNeighbors(queryVector, maxCount)` query condition and the new "find with scores" query methods (the score is the distance to the query vector). For example, find the 2 closest cities:

```swift
let madrid = [40.416775, -3.703790]
let query = try box
        .query { City.coordinates.nearestNeighbors(queryVector: madrid, maxCount: 2) }
        .build()
let closest = query.findWithScores()[0].object
```

For an introduction to Vector Search, more details and other supported languages see the [Vector Search documentation](https://docs.objectbox.io/ann-vector-search).

- Built with Xcode 15.0.1 and Swift 5.9.
- The generator now displays an error when using an index on a property type that can not be indexed.
- Update to [ObjectBox C 4.0.1](https://github.com/objectbox/objectbox-c/releases/tag/v4.0.1).

## 2.0.0 - 2024-05-15

- Built with Xcode 15.0.1 and Swift 5.9.
- Support creating file-less in-memory databases, e.g. for caching and testing. To create one instead of a directory path pass `memory:` together with an identifier string when creating a `Store`:

  ```swift
  inMemoryStore = try Store(directoryPath: "memory:test-db");
  ```

  See the `Store` documentation for details.
- Change `Store.closeAndDeleteAllFiles()` to support deleting an in-memory database.
- Removed some deprecated APIs:
  - Removed `findIntegers()` for property query, replaced by `find()`.
  - Removed `find()` of `Box`, replaced by `all()`.
- Update to [ObjectBox C 4.0.0](https://github.com/objectbox/objectbox-c/releases/tag/v4.0.0).

## Previous versions

See the [changelog in the documentation](https://swift.objectbox.io/).

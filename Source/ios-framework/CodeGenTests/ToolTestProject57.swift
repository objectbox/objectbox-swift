//
//  ToolTestProject56.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 22.10.19.
//  Copyright © 2019 Uli Kusterer. All rights reserved.
//

import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class BusRoute: Entity {
    var id: EntityId<BusRoute> = 0
    var lineNumber: Int = 0
    var driverName: Optional<String>
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB57/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let busBox = store.box(for: BusRoute.self)

    do {
        let testRoute = BusRoute()
        testRoute.lineNumber = 8
        testRoute.driverName = "Sally Swift"
        
        let testRoute2 = BusRoute()
        testRoute2.lineNumber = 42

        try busBox.put(testRoute)
        try busBox.put(testRoute2)

        let results = try busBox.query { BusRoute.driverName.isNil() }.build().find()
        if results.count != 1 {
            throw TestErrors.testFailed(message: "Expected 1 result, found \(results.count)")
        }
        if let driverName = results.first?.driverName {
            throw TestErrors.testFailed(message: "Expected NIL result, found \(driverName)")
        }
        if results.first!.lineNumber != 42 {
            throw TestErrors.testFailed(message: "Expected 42 result, found \(results.first!.lineNumber)")
        }
    } catch TestErrors.testFailed(let message) {
        print("error: \(message)")
        return 1
    } catch {
        print("error: \(error)")
        return 1
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

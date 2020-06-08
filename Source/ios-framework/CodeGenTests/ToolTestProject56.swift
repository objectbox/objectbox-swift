//
//  ToolTestProject56.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 22.10.19.
//  Copyright © 2019 Uli Kusterer. All rights reserved.
//

import ObjectBox


@propertyWrapper
struct Wrapped<T: ExpressibleByIntegerLiteral> {
    private var myInt: T = 0
    var wrappedValue: T {
        get { return myInt }
        set(newValue) { myInt = newValue }
    }
    
    init(wrappedValue: T = 0) {
        myInt = wrappedValue
    }
}

class BusRoute: Entity {
    // Underlying variable for the wrapper is named with an underscore, but we already define _id in the binding:
    // objectbox: id
    @Wrapped var idNumber: EntityId<BusRoute> = 0
    @Wrapped var lineNumber: Int = 0
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.lineNumber = 8
    
    print("line: \(testRoute.lineNumber)")
    
    return 0
}

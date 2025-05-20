//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright 2018-2025 ObjectBox. All rights reserved.
//

/// See `ToolTestProject52.swift` on how this is used.

import ObjectBox


class BusRoute: Entity {
    var id: EntityId<BusRoute> = 0
    var lineName: String = ""
    var finalStop: String = ""

    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.lineName = "U6"
    testRoute.finalStop = "Garching Forschungszentrum"

    print("line \(testRoute.lineName) to \(testRoute.finalStop)")
    
    return 0
}

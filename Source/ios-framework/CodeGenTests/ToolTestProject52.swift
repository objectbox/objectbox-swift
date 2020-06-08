//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class BusRoute: Entity {
    var id: EntityId<BusRoute> = 0
    // objectbox:uid = 8416893018752217856
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

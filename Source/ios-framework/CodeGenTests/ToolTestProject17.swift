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
    // removed annotation "objectbox: index" in a previous run
    var lineName: String = ""
    // objectbox: index
    var destinationName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.lineName = "Clothes Line"
    testRoute.destinationName = "The Hamper"

    return 0
}

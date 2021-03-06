//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class WashingMachine: Entity {
    var id: EntityId<WashingMachine> = 0
    // objectbox: uid = 15616
    var dryerRack: String = ""
    var destinationName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = WashingMachine()
    testRoute.dryerRack = "Clothes Line"
    testRoute.destinationName = "The Hamper"

    return 0
}

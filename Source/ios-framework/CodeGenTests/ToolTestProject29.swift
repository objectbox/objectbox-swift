//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class Building: Entity {
    var id: EntityId<Building> = 0
    var buildingName: String = ""
    var buildingNumber: Int = 0
    
    required init() {}
}

// objectbox: uid = 25600
class Autobus: Entity {
    var id: EntityId<Autobus> = 0
    var lineName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = Autobus()
    testRoute.lineName = "U6"
    
    print("line: \(testRoute.lineName)")
    
    let testBuilding = Building()
    testBuilding.buildingName = "Reinhöfli"
    testBuilding.buildingNumber = 5

    print("building: \(testBuilding.buildingName)")

    return 0
}

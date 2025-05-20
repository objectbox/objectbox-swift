//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright 2018-2025 ObjectBox. All rights reserved.
//

/// Tests the model JSON file is not overwritten on a generator ID error.
///
/// The existing model file (`expected/model/model52.before.json`) was generated
/// using `ToolTestProject52_original.swift`. To assert there are no changes, it
/// is also used as the expected model file (`expected/model/model52.json`).
///
/// The entity triggers an ID error (DuplicatePropertyID)by assigning the
/// existing UID of `finalStop` to `lineName`.

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

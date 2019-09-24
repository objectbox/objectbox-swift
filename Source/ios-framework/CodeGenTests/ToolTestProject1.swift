//
//  ToolTestProject1.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


// objectbox: entity
class BusRoute {
    var id: EntityId<BusRoute> = 0
    var lineName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.lineName = "U8"
    
    print("line: \(testRoute.lineName)")
    
    return 0
}

//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox

// objectbox: entity
// objectbox: sync = { "sharedGlobalIds": true }
class BusRoute {
    var id: EntityId<BusRoute> = 0
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    _ = BusRoute()
    
    return 0
}

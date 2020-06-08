//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class BusRoute: Entity {
    var someId: EntityId<BusRoute> = 0
    var anotherId: EntityId<BusRoute> = 0
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    _ = BusRoute()
    
    return 0
}

//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class BusRoute: Entity {
    var someId: Id<BusRoute> = 0
    var anotherId: Id<BusRoute> = 0
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    _ = BusRoute()
    
    return 0
}

//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class BusRoute: Entity {
    var lineName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.lineName = "U6"
    
    print("line: \(testRoute.lineName)")
    
    return 0
}

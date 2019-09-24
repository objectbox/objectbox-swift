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
    var text: String = ""
    // objectbox: name = "text"
    var Text: String = ""

    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let testRoute = BusRoute()
    testRoute.text = "This"
    testRoute.Text = "That"

    print("first: \(testRoute.text) second: \(testRoute.Text)")
    
    return 0
}

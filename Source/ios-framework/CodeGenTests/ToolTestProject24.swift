//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 13.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class Spaceship: Entity {
    var id: EntityId<Spaceship> = 0
    // objectbox: uid = 13762
    var wibblyWobblyTimeyWimey: String = ""
    var destinationName: String = ""
    
    required init() {}
}

func main(_ args: [String]) throws -> Int32 {
    let spaceship = Spaceship()
    spaceship.wibblyWobblyTimeyWimey = "Stuff"
    spaceship.destinationName = "The Medusa Cascades"

    return 0
}

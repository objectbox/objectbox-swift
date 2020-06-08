//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class Building: Entity, CustomDebugStringConvertible {
    var id: EntityId<Building> = 0
    // objectbox: unique
    var buildingName: String = ""
    var buildingNumber: Int = 0
    
    required init() {}

    public var debugDescription: String {
        get {
            return "Building {\n\tbuildingName = \(buildingName)\n\tbuildingNumber = \(buildingNumber)\n\thasID = \(id.value != 0)\n}\n"
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB30/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let buildingBox = store.box(for: Building.self)

    var firstUniqueID: EntityId<Building>?
    var secondNonUniqueID: EntityId<Building>?
    var thirdUniqueID: EntityId<Building>?
    var fourthUniqueID: EntityId<Building>?

    do {
        let testBuilding1 = Building()
        testBuilding1.buildingName = "Reinhöfli"
        testBuilding1.buildingNumber = 5
        firstUniqueID = try buildingBox.put(testBuilding1)
        
        let testBuilding2 = Building()
        testBuilding2.buildingName = "Reinhöfli"
        testBuilding2.buildingNumber = 77
        secondNonUniqueID = try buildingBox.put(testBuilding2)

        print("error: Got past adding a second same-named object without a Swift error!")

    } catch ObjectBoxError.uniqueViolation {
        print("note: As expected, received not-unique error.")
    } catch {
        print("error: \(error)")
    }

    do {
        let testBuilding1 = Building()
        testBuilding1.buildingName = "Rosenaustraße"
        testBuilding1.buildingNumber = 53
        thirdUniqueID = try buildingBox.put(testBuilding1)
        
        let testBuilding2 = Building()
        testBuilding2.buildingName = "Reinhöfli 2"
        testBuilding2.buildingNumber = 77
        fourthUniqueID = try buildingBox.put(testBuilding2)
        
        print("note: Added two more unique-named objects without ill effect.")
        
    } catch {
        print("error: \(error)")
    }

    let retrievedBuilding1 = try buildingBox.get(firstUniqueID!)
    if retrievedBuilding1 == nil {
        print("error: Could not retrieve first building written.")
    } else {
        print("note: As expected, first building written.")
    }
    if let secondNonUniqueID = secondNonUniqueID {
        if try buildingBox.get(secondNonUniqueID) != nil {
            print("error: Non-unique building was written despite everything.")
        } else {
            print("error: Received a building ID for writing the non-unique building.")
        }
    } else {
        print("note: As expected, second building not written.")
    }
    let retrievedBuilding3 = try buildingBox.get(thirdUniqueID!)
    if retrievedBuilding3 == nil {
        print("error: Could not retrieve third building written.")
    } else {
        print("note: As expected, third building written.")
    }
    let retrievedBuilding4 = try buildingBox.get(fourthUniqueID!)
    if retrievedBuilding4 == nil {
        print("error: Could not retrieve fourth building written.")
    } else {
        print("note: As expected, fourth building written.")
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

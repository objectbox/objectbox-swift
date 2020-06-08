//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


struct Building: Entity, CustomDebugStringConvertible {
    let id: EntityId<Building>
    let buildingName: String
    let buildingNumber: Int

    public var debugDescription: String {
        get {
            return "Building {\n\tbuildingName = \(buildingName)\n\tbuildingNumber = \(buildingNumber)\n\thasID = \(id.value != 0)\n}\n"
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB31/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let buildingBox = store.box(for: Building.self)

    do {
        let testBuilding1 = Building(id: 0, buildingName: "Reinhöfli", buildingNumber: 0)
        let building1Id = try buildingBox.put(testBuilding1)
        guard building1Id.value != 0 else { print("error: Couldn't write building 1."); return 1 }

        let testBuilding2 = Building(id: 0, buildingName: "Hildisriederstr.", buildingNumber: 5)
        let building2Written = try buildingBox.put(struct: testBuilding2)
        guard building2Written.id.value != 0 else { print("error: Couldn't write building 2."); return 1 }

        let moreBuildings = try buildingBox.put(structs: [
            Building(id: 0, buildingName: "Hildisriederstr.", buildingNumber: 6),
            Building(id: 0, buildingName: "Reinhöfli", buildingNumber: 1)])
        if moreBuildings.count != 2 {
            print("error: Couldn't write \(2 - moreBuildings.count) of 2 more objects."); return 1
        }
        if moreBuildings[0].id == 0 {
            print("error: Couldn't write moreBuildings[0]."); return 1
        }
        if moreBuildings[1].id == 0 {
            print("error: Couldn't write moreBuildings[1]."); return 1
        }

        guard let retrievedBuilding1 = try buildingBox.get(building1Id) else { print("error: Couldn't read back building 1."); return 1 }
        guard let retrievedBuilding2 = try buildingBox.get(building2Written.id) else { print("error: Couldn't read back building 2."); return 1 }

        guard building1Id.value == retrievedBuilding1.id.value else { print("error: Building 1 read with wrong ID."); return 1 }
        guard building2Written.id.value == retrievedBuilding2.id.value else { print("error: Building 2 read with wrong ID."); return 1 }

        guard retrievedBuilding1.buildingNumber == testBuilding1.buildingNumber && retrievedBuilding1.buildingName == testBuilding1.buildingName else { print("error: Building 1 contents don't match."); return 1 }
        guard retrievedBuilding2.buildingNumber == testBuilding2.buildingNumber && retrievedBuilding2.buildingName == testBuilding2.buildingName else { print("error: Building 2 contents don't match."); return 1 }
    } catch {
        print("error: \(error)")
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

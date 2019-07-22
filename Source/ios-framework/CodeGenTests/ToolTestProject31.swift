//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


struct Building: Entity, CustomDebugStringConvertible {
    let id: Id<Building>
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
        let building1Id = try buildingBox.putImmutable(testBuilding1)
        guard building1Id.value != 0 else { print("error: Couldn't write building 1."); return 1 }

        let testBuilding2 = Building(id: 0, buildingName: "Hildisriederstr.", buildingNumber: 5)
        let building2Written = try buildingBox.put(struct: testBuilding2)
        guard building2Written.id.value != 0 else { print("error: Couldn't write building 2."); return 1 }

        guard let retrievedBuilding1 = buildingBox.get(building1Id) else { print("error: Couldn't read back building 1."); return 1 }
        guard let retrievedBuilding2 = buildingBox.get(building2Written.id) else { print("error: Couldn't read back building 2."); return 1 }

        guard building1Id.value == retrievedBuilding1.id.value else { print("error: Building 1 read with wrong ID."); return 1 }
        guard building2Written.id.value == retrievedBuilding2.id.value else { print("error: Building 2 read with wrong ID."); return 1 }

        guard retrievedBuilding1.buildingNumber == testBuilding1.buildingNumber && retrievedBuilding1.buildingName == testBuilding1.buildingName else { print("error: Building 1 contents don't match."); return 1 }
        guard retrievedBuilding2.buildingNumber == testBuilding2.buildingNumber && retrievedBuilding2.buildingName == testBuilding2.buildingName else { print("error: Building 2 contents don't match."); return 1 }
    } catch {
        print("error: \(error)")
    }
    
    print("note: Ran \(args.first ?? "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

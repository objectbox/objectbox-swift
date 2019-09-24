//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class Building: Entity, CustomDebugStringConvertible {
    // objectbox:id
    var id: UInt64 = 0
    var buildingName: String
    var buildingNumber: Int
    
    init(buildingName: String = "", buildingNumber: Int = 0) {
        self.buildingName = buildingName
        self.buildingNumber = buildingNumber
    }

    public var debugDescription: String {
        get {
            return "Building {\n\tbuildingName = \(buildingName)\n\tbuildingNumber = \(buildingNumber)\n\thasID = \(id != 0)\n}\n"
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB32/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let buildingBox = store.box(for: Building.self)

    do {
        let testBuilding1 = Building(buildingName: "Reinhöfli", buildingNumber: 0)
        try buildingBox.put(testBuilding1)
        guard testBuilding1.id != 0 else { print("error: Couldn't write building 1."); return 1 }

        guard let readBuilding1 = try buildingBox.get(EntityId<Building>(testBuilding1.id)) else { print("error: Couldn't read building 1."); return 1 }
        guard testBuilding1.id == readBuilding1.id else { print("error: Read building 1 ID isn't the one written."); return 1 }
        guard testBuilding1.buildingName == readBuilding1.buildingName else { print("error: Read building 1 name isn't the one written."); return 1 }
        guard testBuilding1.buildingNumber == readBuilding1.buildingNumber else { print("error: Read building 1 number isn't the one written."); return 1 }

    } catch {
        print("error: \(error)")
        return 1
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

//
//  main.swift
//  ToolTestProject
//
//  Created by Uli Kusterer on 07.12.18.
//  Copyright © 2018 Uli Kusterer. All rights reserved.
//

import ObjectBox


class TestEnumConverter {
    static func convert(_ enumerated: TestEnum) -> Int {
        return enumerated.rawValue
    }
    static func convert(_ num: Int) -> TestEnum {
        return TestEnum(rawValue: num) ?? TestEnum.unset
    }
}


enum TestEnum: Int {
    case unset = 0
    case first = 100
    case second = 200
    case third = 300
}


class EnumEntity: Entity, CustomDebugStringConvertible {
    // objectbox:id
    var id: UInt64 = 0
    // objectbox: convert = { "dbType": "Int", "converter": "TestEnumConverter" }
    var custom: TestEnum
    
    init(custom: TestEnum = .unset) {
        self.custom = custom
    }

    public var debugDescription: String {
        get {
            return "EnumEntity {\n\tcustom = \(custom)\n\thasID = \(id != 0)\n}\n"
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB34/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let enumBox = store.box(for: EnumEntity.self)

    do {
        let testEnumEntity1 = EnumEntity(custom: .first)
        try enumBox.put(testEnumEntity1)
        guard testEnumEntity1.id != 0 else { print("error: Couldn't write entity 1."); return 1 }

        guard let readEnumEntity1 = try enumBox.get(EntityId<EnumEntity>(testEnumEntity1.id)) else { print("error: Couldn't read entity 1."); return 1 }
        guard testEnumEntity1.id == readEnumEntity1.id else { print("error: Read entity 1 ID isn't the one written."); return 1 }
        guard testEnumEntity1.custom == readEnumEntity1.custom else { print("error: Read entity 1 enum isn't the one written."); return 1 }

    } catch {
        print("error: \(error)")
        return 1
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

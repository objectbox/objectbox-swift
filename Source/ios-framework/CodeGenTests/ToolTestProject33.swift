import ObjectBox


class DataThing: Entity, CustomDebugStringConvertible {
    var id: EntityId<DataThing> = 0
    var firstData: Data
    var secondData: [UInt8]
    var maybeThirdData: Data?
    var maybeFourthData: [UInt8]?

    init(firstData: String = "", secondData: [UInt8] = [], maybeThirdData: String? = nil, maybeFourthData: [UInt8]? = nil) {
        self.firstData = firstData.data(using: .utf8)!
        self.secondData = secondData
        self.maybeThirdData = maybeThirdData?.data(using: .utf8)
        self.maybeFourthData = maybeFourthData
    }

    public var debugDescription: String {
        get {
            return "DataThing {\n\tfirstData = \(String(data: firstData, encoding: .utf8)!)\n\tsecondData = \(secondData)\n\tmaybeThirdData = \(maybeThirdData != nil ? String(data: maybeThirdData!, encoding: .utf8)! : "(null)")\n\tmaybeFourthData = \(maybeFourthData != nil ? "\(maybeFourthData!)" : "(null)")\n}\n"
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB33/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)
    
    let store = try Store(directoryPath: storeFolder.path)
    
    let box = store.box(for: DataThing.self)

    do {
        let records = [
            DataThing(firstData: "Enid Blyton", secondData: [1, 2, 3], maybeThirdData: "Richmal Crompton", maybeFourthData: [4, 5, 6]),
            DataThing(firstData: "PL Travers", secondData: [7]),
            DataThing(firstData: "Ursula LeGuin", secondData: []),
            DataThing(firstData: "Diana Wynne Jones", secondData: [9, 9, 9, 9, 9, 9, 9, 9, 9]),
            DataThing(firstData: "Margaret Storey", secondData: [8, 9, 10, 11])
        ]
        
        try box.put(records)
        
        let numAvailable = try box.count()
        if numAvailable != records.count {
            print("error: Expected \(records.count) entities, only \(numAvailable) reported")
            return 1
        }
        
        for entity in records {
            let results = try box.query({ DataThing.firstData == entity.firstData }).build().find()
            if results.count != 1 {
                print("error: Expected one \(entity), \(results.count) found")
                return 1
            }
            if "\(results.first!)" != "\(entity)" {
                print("error: \(results.first!) != \(entity)")
                return 1
            }
        }

    } catch {
        print("error: \(error)")
        return 1
    }
    
    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

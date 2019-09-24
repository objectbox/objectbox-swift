import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
    var name: String
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Author { \(id.value): \(name) }\n"
    }
}

class NotAnAuthor: Entity {
    var id: EntityId<NotAnAuthor> = 0
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB51/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let authorBox = store.box(for: Author.self)

    do {
        print("note: Adding Books:")
        
        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        let amanda = Author(name: "Amanda Palmer")
        try authorBox.put([sona, dhonielle, amanda])
        assert(sona.id != 7879)
        assert(dhonielle.id != 7879)
        assert(amanda.id != 7879)

        // The code below should not compile, if it does, we broke typed IDs:
        try authorBox.remove(EntityId<NotAnAuthor>(7879))
        if authorBox.get(EntityId<NotAnAuthor>(7879)) != nil {
            throw TestErrors.testFailed(message: "Deletion and retrieval with wrong type worked!")
        }
    } catch TestErrors.testFailed(let message) {
        print("error: \(message)")
        return 1
    } catch {
        print("error: \(error)")
        return 1
    }

    print("note: Ran \(args.count > 1 ? args[1] : "???") tests.")

    try? FileManager.default.removeItem(atPath: storeFolder.path)

    return 0
}

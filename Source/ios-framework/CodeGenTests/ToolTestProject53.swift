import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: Id = 0
    var name: String
    // objectbox: backlink = "author"
    var books: ToMany<Book> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Author { \(id.value): \(name) }\n"
    }
}

class Book: Entity, CustomDebugStringConvertible {
    var id: Id = 0
    var name: String
    var author: ToOne<Author> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Book { \(id.value): \(name) by \(String(describing: author.target)) }\n"
    }
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB50/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let authorBox = store.box(for: Author.self)
    let bookBox = store.box(for: Book.self)

    do {
        let symptomsOfAHeartbreak = Book(name: "Symptoms of a Heartbreak") // Sona Charaipotra
        try bookBox.put(symptomsOfAHeartbreak)
        
        let sona = Author(name: "Sona Charaipotra")
        sona.books.replace([symptomsOfAHeartbreak])
        try authorBox.put(sona)
        try bookBox.put(symptomsOfAHeartbreak)
        
        let readSona = try authorBox.get(sona.id)!
        let bookCount = readSona.books.count
        if bookCount != 0 {
            throw TestErrors.testFailed(message: "Author should have no books, has \(bookCount)")
        }
        
        let readSymptomsOfAHeartbreak = try bookBox.get(symptomsOfAHeartbreak.id)!
        if readSymptomsOfAHeartbreak.author.target != nil {
            throw TestErrors.testFailed(message: "Book should have no author.")
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

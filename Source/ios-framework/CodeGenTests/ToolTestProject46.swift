import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
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
    var id: EntityId<Book> = 0
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

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB43/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let authorBox = store.box(for: Author.self)
    let bookBox = store.box(for: Book.self)

    do {
        let relationEditGroup = DispatchGroup()
        let queue = DispatchQueue(label: "io.objectbox.test.workerQueue", attributes: [.concurrent, .initiallyInactive])
        print("note: Adding Books:")

        let adjectives = ["Great", "Small", "Amazing", "New", "Old",
                          "Complete", "Annotated", "Revised", "Extended", "Original",
                          "French", "German", "Russian", "Ukranian", "Italian",
                          "Compact", "Cthulhu", "Papal", "Canonical", "Hitchhiker's"]
        let nouns = ["Visual Dictionary", "Encyclopedia", "Testament", "Guide to the Galaxy", "Cookbook",
                     "Manual", "Language Primer", "Compendium", "Advanced Class", "Teacher",
                     "American Novel", "Decrees of the World", "Atlas", "Expectations Learner", "Guidebook",
                      "Maps", "Handbook", "Holiday List", "Previews", "Digest"]
        
        print("note: Adding Authors:")
        let dhonielle = Author(name: "Dhonielle Clayton")
        try authorBox.put(dhonielle)
        var books = [Book]()

        for aIndex in 0 ..< adjectives.count {
            for nIndex in 0 ..< nouns.count {
                let book = Book(name: "The \(adjectives[aIndex]) \(nouns[nIndex])")
                try bookBox.put(book)
                books.append(book)
                
                relationEditGroup.enter()
                queue.async {
                    dhonielle.books.append(book)
                    try! dhonielle.books.applyToDb()
                    relationEditGroup.leave()
                }
            }
        }
        
        queue.activate() // Increase likelihood of concurrency by only now starting the queue.
        // Once all above have finished, run the put.
        relationEditGroup.wait()
                
        print("note: Testing backlink:")
        let readDhonielle = try authorBox.get(dhonielle.id)!
        let readBookNames = Array(readDhonielle.books).map { $0.name }.sorted()
        let expectedBookNames = books.map { $0.name }.sorted()

        if readBookNames != expectedBookNames {
            throw TestErrors.testFailed(message: "bookNames: Expected \(expectedBookNames), found \(readBookNames)")
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

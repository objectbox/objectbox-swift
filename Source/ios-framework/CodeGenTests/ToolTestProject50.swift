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
        print("note: Adding Books:")

        let symptomsOfAHeartbreak = Book(name: "Symptoms of a Heartbreak") // Sona Charaipotra
        let everlastingRose = Book(name: "The Everlasting Rose") // Dhonielle Clayton
        let theBelles = Book(name: "The Belles") // Dhonielle Clayton
        let theArtOfAsking = Book(name: "The Art of Asking") // Amanda Palmer
        let allBooks = [symptomsOfAHeartbreak, everlastingRose, theBelles, theArtOfAsking]
        try bookBox.put(allBooks)
        
        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        let amanda = Author(name: "Amanda Palmer")
        try authorBox.put([sona, dhonielle, amanda])
        
        print("note: Adding Relation 1:")
        sona.books.replace([symptomsOfAHeartbreak])
        try sona.books.applyToDb()
        
        print("note: Adding Relation 2:")
        dhonielle.books.replace([everlastingRose, theBelles])
        try dhonielle.books.applyToDb()
        
        print("note: Adding Relation 3:")
        amanda.books.replace([theArtOfAsking])
        try amanda.books.applyToDb()
        
        try bookBox.put(allBooks) // We edited the authors, but the books contain the ToOne that needs persisting.
        
        print("note: Testing forward:")
        let dhoniellesBooks = try bookBox.query().link(Book.author) { Author.name == dhonielle.name }.build().find()
        if dhoniellesBooks.count != 2 {
            throw TestErrors.testFailed(message: "Book count wrong. Expected 2, found \(dhoniellesBooks.count)")
        }
        if dhoniellesBooks.first(where: { $0.name == everlastingRose.name }) == nil {
            throw TestErrors.testFailed(message: "Book missing: \(everlastingRose)")
        }
        if dhoniellesBooks.first(where: { $0.name == theBelles.name }) == nil {
            throw TestErrors.testFailed(message: "Book missing: \(theBelles)")
        }
        
        print("note: Testing backlink:")
        let bellesAskingAuthors = try authorBox.query().link(Author.books) {
            Book.name == theBelles.name || Book.name == theArtOfAsking.name
            }.build().find()
        if bellesAskingAuthors.count != 2 {
            throw TestErrors.testFailed(message: "Author count wrong. Expected 2, found \(bellesAskingAuthors.count)")
        }
        if bellesAskingAuthors.first(where: { $0.name == dhonielle.name }) == nil {
            throw TestErrors.testFailed(message: "Author missing: \(dhonielle)")
        }
        if bellesAskingAuthors.first(where: { $0.name == amanda.name }) == nil {
            throw TestErrors.testFailed(message: "Author missing: \(amanda)")
        }

        // This is mainly to ensure compilation isn't broken, but might as well verify that delete works:
        print("note: Doing remove test.")
        try authorBox.remove(amanda.id)
        if let amandaRead = try authorBox.get(amanda.id) {
            throw TestErrors.testFailed(message: "Deletion failed: \(amandaRead)")
        }

        // This is mainly to ensure compilation isn't broken, but might as well verify that delete works:
        print("note: Multi-remove test.")
        let deletions = try authorBox.remove([amanda.id, dhonielle.id])
        if deletions != 1 { // Amanda has already been deleted.
            throw TestErrors.testFailed(message: "Expected 1 deletion, got \(deletions)")
        }
        if let dhonielleRead = try authorBox.get(dhonielle.id) {
            throw TestErrors.testFailed(message: "Deletion failed: \(dhonielleRead)")
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

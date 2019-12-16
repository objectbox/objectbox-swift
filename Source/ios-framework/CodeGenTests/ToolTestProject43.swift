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
                
        print("note: Testing forward:")
        let dhoniellesBooks = try bookBox.query().link(Book.author) { Author.name == dhonielle.name }.build().find()
        if dhoniellesBooks.count != 2 {
            print("error: Book count wrong. Expected 2, found \(dhoniellesBooks.count)")
            return 1
        }
        if dhoniellesBooks.first(where: { $0.name == everlastingRose.name }) == nil {
            print("error: Book missing: \(everlastingRose)")
            return 1
        }
        if dhoniellesBooks.first(where: { $0.name == theBelles.name }) == nil {
            print("error: Book missing: \(theBelles)")
            return 1
        }
        
        print("note: Testing backlink:")
        let bellesAskingAuthors = try authorBox.query().link(Author.books) {
            Book.name == theBelles.name || Book.name == theArtOfAsking.name
            }.build().find()
        if bellesAskingAuthors.count != 2 {
            print("error: Author count wrong. Expected 2, found \(bellesAskingAuthors.count)")
            return 1
        }
        if bellesAskingAuthors.first(where: { $0.name == dhonielle.name }) == nil {
            print("error: Author missing: \(dhonielle)")
            return 1
        }
        if bellesAskingAuthors.first(where: { $0.name == amanda.name }) == nil {
            print("error: Author missing: \(amanda)")
            return 1
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

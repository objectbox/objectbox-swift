import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

struct Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
    var name: String
    var books: ToMany<Book> = nil
    
    init(id: EntityId<Author> = 0, name: String = "", books: ToMany<Book> = nil) {
        self.id = id
        self.name = name
        self.books = books
    }
    
    public var debugDescription: String {
        return "Author { \(name), \(id) }\n"
    }
}

struct Book: Entity, CustomDebugStringConvertible {
    var id: EntityId<Book> = 0
    var name: String
    // objectbox: backlink = "books"
    var authors: ToMany<Author> = nil
    
    init(id: EntityId<Book> = 0, name: String = "", authors: ToMany<Author> = nil) {
        self.id = id
        self.name = name
        self.authors = authors
    }
    
    public var debugDescription: String {
        return "Book { \(name), \(id) }\n"
    }
}

func testOneBook(_ book: Book, authors: [Author], bookBox: Box<Book>) throws {
    print("Reading book \(book)")
    guard let bookRead = try bookBox.get(book.id) else {
        throw TestErrors.testFailed(message: "Couldn't find book \(book)")
    }
    if bookRead.authors.count != authors.count {
        throw TestErrors.testFailed(message: "Author count for \(book) is \(bookRead.authors.count) not \(authors.count)\n\(bookRead.authors)")
    }
    for currAuthor in authors {
        if Array(bookRead.authors).first(where: { $0.id == currAuthor.id && $0.name == currAuthor.name }) == nil {
            throw TestErrors.testFailed(message: "Wrong author in \(book)\n\(bookRead.authors)")
        }
    }
}

func testOneAuthor(_ author: Author, books: [Book], authorBox: Box<Author>) throws {
    print("Reading author \(author)")
    guard let authorRead = try authorBox.get(author.id) else {
        throw TestErrors.testFailed(message: "Couldn't find author \(author)")
    }
    if authorRead.books.count != books.count {
        throw TestErrors.testFailed(message: "Book count for \(author) is \(authorRead.books.count) not \(books.count)\n\(authorRead.books)")
    }
    for currBook in books {
        if Array(authorRead.books).first(where: { $0.id == currBook.id && $0.name == currBook.name }) == nil {
            throw TestErrors.testFailed(message: "Wrong book in \(author)\n\(authorRead.books)")
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB40/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let authorBox = store.box(for: Author.self)
    let bookBox = store.box(for: Book.self)

    do {
        print("note: Adding Books:")

        let tinyPrettyThings = Book(name: "Tiny Pretty Things") // Sona Charaipotra, Dhonielle Clayton
        let symptomsOfAHeartbreak = Book(name: "Symptoms of a Heartbreak") // Sona Charaipotra
        let everlastingRose = Book(name: "The Everlasting Rose") // Dhonielle Clayton
        let assignedBookIds = try bookBox.putAndReturnIDs( [tinyPrettyThings, symptomsOfAHeartbreak, everlastingRose] )
        let tinyPrettyThings2 = try bookBox.get(assignedBookIds[0])!
        let symptomsOfAHeartbreak2 = try bookBox.get(assignedBookIds[1])!
        let everlastingRose2 = try bookBox.get(assignedBookIds[2])!

        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        let assignedAuthorIds = try authorBox.putAndReturnIDs([sona, dhonielle])
        let sona2 = try authorBox.get(assignedAuthorIds[0])!
        let dhonielle2 = try authorBox.get(assignedAuthorIds[1])!

        print("note: Adding Relation 1:")
        tinyPrettyThings2.authors.replace([sona2, dhonielle2])
        try tinyPrettyThings2.authors.applyToDb()
        
        print("note: Adding Relation 2:")
        symptomsOfAHeartbreak2.authors.replace([sona2])
        try symptomsOfAHeartbreak2.authors.applyToDb()
        
        print("note: Adding Relation 3:")
        everlastingRose2.authors.replace([dhonielle2])
        try everlastingRose2.authors.applyToDb()
        
        try testOneBook(tinyPrettyThings2, authors: [sona2, dhonielle2], bookBox: bookBox)
        try testOneBook(symptomsOfAHeartbreak2, authors: [sona2], bookBox: bookBox)
        try testOneBook(everlastingRose2, authors: [dhonielle2], bookBox: bookBox)
        
        try testOneAuthor(sona2, books: [tinyPrettyThings2, symptomsOfAHeartbreak2], authorBox: authorBox)
        try testOneAuthor(dhonielle2, books: [tinyPrettyThings2, everlastingRose2], authorBox: authorBox)
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

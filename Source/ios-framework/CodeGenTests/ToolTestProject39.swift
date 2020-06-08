import ObjectBox

enum TestErrors: Error {
    case testFailed(message: String)
}

struct Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
    var name: String
    // objectbox: backlink = "author"
    var books: ToMany<Book> = nil
    
    init(id: EntityId<Author> = EntityId<Author>(0), name: String = "", books: ToMany<Book> = nil) {
        self.id = id
        self.name = name
        self.books = books
    }
    
    public var debugDescription: String {
        return "Author { \(id.value): \(name) }\n"
    }
}

struct Book: Entity, CustomDebugStringConvertible {
    var id: EntityId<Book> = 0
    var name: String
    var author: ToOne<Author> = nil
    
    init(id: EntityId<Book> = EntityId<Book>(0), name: String = "", author: ToOne<Author> = nil) {
        self.id = id
        self.name = name
        self.author = author
    }
    
    public var debugDescription: String {
        return "Book { \(id.value): \(name) by \(String(describing: author.target)) }\n"
    }
}

func testOneBook(_ book: Book, author: Author, bookBox: Box<Book>) throws {
    print("Reading book \(book.name)")
    guard let bookRead = try bookBox.get(book.id) else {
        throw TestErrors.testFailed(message: "Couldn't find book \(book.name)")
    }
    if bookRead.author.target?.id != author.id || bookRead.author.target?.name != author.name {
        throw TestErrors.testFailed(message: "Wrong author in \(book.name)Read\n"
            + "\(String(describing: bookRead.author.target))")
    }
}

func testOneAuthor(_ author: Author, books: [Book], authorBox: Box<Author>) throws {
    print("Reading author \(author.name)")
    guard let authorRead = try authorBox.get(author.id) else {
        throw TestErrors.testFailed(message: "Couldn't find author \(author.name)")
    }
    if authorRead.books.count != books.count {
        throw TestErrors.testFailed(message: "Book count for \(author.name) is \(authorRead.books.count) not \(books.count)\n\(authorRead.books)")
    }
    for currBook in books {
        if Array(authorRead.books).first(where: { $0.id == currBook.id && $0.name == currBook.name }) == nil {
            throw TestErrors.testFailed(message: "Wrong book in \(author.name)Read\n\(authorRead.books)")
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB39/")
    try? FileManager.default.removeItem(atPath: storeFolder.path)
    try FileManager.default.createDirectory(at: storeFolder, withIntermediateDirectories: false)

    print("note: Creating DB at \(storeFolder.path)")
    
    let store = try Store(directoryPath: storeFolder.path)

    print("note: Getting boxes")
    let authorBox = store.box(for: Author.self)
    let bookBox = store.box(for: Book.self)

    do {
        print("note: Adding Books:")
        
        let symptomsOfAHeartbreak1 = Book(name: "Symptoms of a Heartbreak") // Sona Charaipotra
        let everlastingRose1 = Book(name: "The Everlasting Rose") // Dhonielle Clayton
        let theBelles1 = Book(name: "The Belles") // Dhonielle Clayton
        let assignedBookIds = try bookBox.putAndReturnIDs([symptomsOfAHeartbreak1, everlastingRose1, theBelles1])
        let symptomsOfAHeartbreak2 = try bookBox.get(assignedBookIds[0])!
        let everlastingRose2 = try bookBox.get(assignedBookIds[1])!
        let theBelles2 = try bookBox.get(assignedBookIds[2])!
        
        print("note: Adding Authors:")
        var sona = Author(name: "Sona Charaipotra")
        var dhonielle = Author(name: "Dhonielle Clayton")
        let assignedAuthorIds = try authorBox.putAndReturnIDs([sona, dhonielle])
        sona = try authorBox.get(assignedAuthorIds[0])!
        dhonielle = try authorBox.get(assignedAuthorIds[1])!

        print("note: Adding Relation 1:")
        sona.books.replace([symptomsOfAHeartbreak2])
        try sona.books.applyToDb()
        
        print("note: Adding Relation 2:")
        dhonielle.books.replace([everlastingRose2, theBelles2])
        try dhonielle.books.applyToDb()
        
        print("note: Writing it all out:")
        
        try testOneBook(symptomsOfAHeartbreak2, author: sona, bookBox: bookBox)
        try testOneBook(everlastingRose2, author: dhonielle, bookBox: bookBox)
        try testOneBook(theBelles2, author: dhonielle, bookBox: bookBox)
        
        try testOneAuthor(sona, books: [symptomsOfAHeartbreak2], authorBox: authorBox)
        try testOneAuthor(dhonielle, books: [everlastingRose2, theBelles2], authorBox: authorBox)
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

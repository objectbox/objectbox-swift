import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
    var name: String
    var books: ToMany<Book, Author> = nil
    
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
    // objectbox: backlink = "books"
    var author: ToOne<Author> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Book { \(id.value): \(name) by \(String(describing: author.target)) }\n"
    }
}

func testOneBook(_ book: Book, author: Author, bookBox: Box<Book>) throws {
    print("Reading book \(book.name)")
    guard let bookRead = bookBox.get(book.id) else {
        throw TestErrors.testFailed(message: "Couldn't find book \(book.name)")
    }
    if bookRead.author.target?.id != author.id || bookRead.author.target?.name != author.name {
        throw TestErrors.testFailed(message: "Wrong author in \(book.name)Read\n"
            + "\(String(describing: bookRead.author.target))")
    }
}

func testOneAuthor(_ author: Author, books: [Book], authorBox: Box<Author>) throws {
    print("Reading author \(author.name)")
    guard let authorRead = authorBox.get(author.id) else {
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

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB41/")
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
        let allBooks = [symptomsOfAHeartbreak, everlastingRose, theBelles]
        try bookBox.put(allBooks)
        
        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        try authorBox.put([sona, dhonielle])
        
        print("note: Adding Relation 1:")
        sona.books.replace([symptomsOfAHeartbreak])

        print("note: Adding Relation 2:")
        dhonielle.books.replace([everlastingRose, theBelles])

        try bookBox.put(allBooks) // We edited the authors, but the books contain the ToOne that needs persisting.
        
        try testOneBook(symptomsOfAHeartbreak, author: sona, bookBox: bookBox)
        try testOneBook(everlastingRose, author: dhonielle, bookBox: bookBox)
        try testOneBook(theBelles, author: dhonielle, bookBox: bookBox)

        try testOneAuthor(sona, books: [symptomsOfAHeartbreak], authorBox: authorBox)
        try testOneAuthor(dhonielle, books: [everlastingRose, theBelles], authorBox: authorBox)
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

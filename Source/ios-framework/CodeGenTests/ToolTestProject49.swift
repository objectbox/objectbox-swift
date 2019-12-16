import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: Id = 0
    var name: String
    var books: ToMany<Book> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Author { \(name) }\n"
    }
}

class Book: Entity, CustomDebugStringConvertible {
    var id: Id = 0
    var name: String
    // objectbox: backlink = "books"
    var authors: ToMany<Author> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Book { \(name) }\n"
    }
}

func testOneBook(_ book: Book, authors: [Author], bookBox: Box<Book>) throws {
    print("Reading book \(book.name)")
    guard let bookRead = try bookBox.get(book.id) else {
        throw TestErrors.testFailed(message: "Couldn't find book \(book.name)")
    }
    if bookRead.authors.count != authors.count {
        throw TestErrors.testFailed(message: "Author count for \(book.name) is \(bookRead.authors.count) not \(authors.count)\n\(bookRead.authors)")
    }
    for currAuthor in authors {
        if Array(bookRead.authors).first(where: { $0.id == currAuthor.id && $0.name == currAuthor.name }) == nil {
            throw TestErrors.testFailed(message: "Wrong author in \(book.name)Read\n\(bookRead.authors)")
        }
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

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB49/")
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
        try bookBox.put( [tinyPrettyThings, symptomsOfAHeartbreak, everlastingRose] )
        
        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        try authorBox.put( [sona, dhonielle] )
        
        print("note: Adding Relation 1:")
        tinyPrettyThings.authors.replace([sona, dhonielle])
        try tinyPrettyThings.authors.applyToDb()
        
        print("note: Adding Relation 2:")
        symptomsOfAHeartbreak.authors.replace([sona])
        try symptomsOfAHeartbreak.authors.applyToDb()
        
        print("note: Adding Relation 3:")
        everlastingRose.authors.replace([dhonielle])
        try everlastingRose.authors.applyToDb()
        
        print("note: Testing forward:")
        // Could do this without a relation by just looking for the book by name & asking for its authors,
        //  but we're testing queries over relations here, so do it the complicated way:
        let tinyPrettyThingsAuthors = try authorBox.query().link(Author.books) { Book.name == tinyPrettyThings.name }.build().find()
        if tinyPrettyThingsAuthors.count != 2 {
            print("error: Author count wrong. Expected 2, found \(tinyPrettyThingsAuthors.count)")
            return 1
        }
        if tinyPrettyThingsAuthors.first(where: { $0.name == sona.name }) == nil {
            print("error: Author missing: \(sona)")
            return 1
        }
        if tinyPrettyThingsAuthors.first(where: { $0.name == dhonielle.name }) == nil {
            print("error: Author missing: \(dhonielle)")
            return 1
        }

        print("note: Testing backlink:")
        let sonasBooks = try bookBox.query().link(Book.authors) { Author.name == sona.name }.build().find()
        if sonasBooks.count != 2 {
            print("error: Book count wrong. Expected 2, found \(sonasBooks.count)")
            return 1
        }
        if sonasBooks.first(where: { $0.name == tinyPrettyThings.name }) == nil {
            print("error: Book missing: \(tinyPrettyThings)")
            return 1
        }
        if sonasBooks.first(where: { $0.name == symptomsOfAHeartbreak.name }) == nil {
            print("error: Book missing: \(symptomsOfAHeartbreak)")
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

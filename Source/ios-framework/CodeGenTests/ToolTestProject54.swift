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
        let symptomsOfAHeartbreak = Book(name: "Symptoms of a Heartbreak")
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
        let authorCount = readSymptomsOfAHeartbreak.authors.count
        if authorCount != 0 {
            throw TestErrors.testFailed(message: "Book should have no authors, has \(authorCount)")
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

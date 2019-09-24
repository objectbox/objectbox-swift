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
        return "Author { \(name) }\n"
    }
}

class Book: Entity, CustomDebugStringConvertible {
    var id: EntityId<Book> = 0
    var name: String
    var authors: ToMany<Author> = nil
    
    init(name: String = "") {
        self.name = name
    }
    
    public var debugDescription: String {
        return "Book { \(name) }\n"
    }
}

func testOneBook(_ name: String, id: EntityId<Book>, authors: [Author], bookBox: Box<Book>) throws {
    print("Reading book \(name)")
    guard let bookRead = try bookBox.get(id) else {
        throw TestErrors.testFailed(message: "Couldn't find book \(name)")
    }
    if bookRead.authors.count != authors.count {
        throw TestErrors.testFailed(message: "Author count for \(name) is \(bookRead.authors.count) not \(authors.count)\n\(bookRead.authors)")
    }
    for currAuthor in authors {
        if Array(bookRead.authors).first(where: { $0.id == currAuthor.id && $0.name == currAuthor.name }) == nil {
            throw TestErrors.testFailed(message: "Wrong author in \(name)Read\n\(bookRead.authors)")
        }
    }
}

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB36/")
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
        let whatIfItsUs = Book(name: "What If It’s Us") // Adam Silvera, Becky Albertalli
        let fledgling = Book(name: "Fledgling") // Octavia Butler
        try bookBox.put( [tinyPrettyThings, whatIfItsUs, fledgling] )
        
        print("note: Adding Authors:")
        let sona = Author(name: "Sona Charaipotra")
        let dhonielle = Author(name: "Dhonielle Clayton")
        let adam = Author(name: "Adam Silvera")
        let becky = Author(name: "Becky Albertalli")
        let tara = Author(name: "Tara ThirdAuthor")
        let octavia = Author(name: "Octavia Butler")
        try authorBox.put( [sona, dhonielle, adam, becky, tara, octavia] )
        
        print("note: Adding Relation 1:")
        tinyPrettyThings.authors.replace([sona, dhonielle])
        try tinyPrettyThings.authors.applyToDb()
        
        print("note: Adding Relation 2:")
        whatIfItsUs.authors.append(adam)
        whatIfItsUs.authors.append(tara) // Add a 3rd author so we see it's not hard-coded to 2 somehow.
        whatIfItsUs.authors.append(becky)
        try whatIfItsUs.authors.applyToDb()
        
        print("note: Adding Relation 3:")
        fledgling.authors.append(octavia)
        try fledgling.authors.applyToDb()
        
        try testOneBook("tinyPrettyThings", id: tinyPrettyThings.id, authors: [sona, dhonielle], bookBox: bookBox)
        try testOneBook("whatIfItsUs", id: whatIfItsUs.id, authors: [adam, becky, tara], bookBox: bookBox)
        try testOneBook("fledgling", id: fledgling.id, authors: [octavia], bookBox: bookBox)
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

import ObjectBox


enum TestErrors: Error {
    case testFailed(message: String)
}

class Author: Entity, CustomDebugStringConvertible {
    var id: EntityId<Author> = 0
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
    var id: EntityId<Book> = 0
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

func main(_ args: [String]) throws -> Int32 {
    print("note: Starting \(args.first ?? "???") tests:")

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB44/")
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

		let readSona = try authorBox.get(sona.id)!
		let unchangedBookNames = Array(readSona.books).map { $0.name }.sorted()
		sona.books.replace([symptomsOfAHeartbreak])
		try sona.books.applyToDb()
		let cachedBookNames = Array(readSona.books).map { $0.name }.sorted()
		readSona.books.reset()
		let updatedBookNames = Array(readSona.books).map { $0.name }.sorted()
		
		if unchangedBookNames != ["Symptoms of a Heartbreak", "Tiny Pretty Things"] {
			throw TestErrors.testFailed(message: "unchangedBookNames: Expected 2 books, found \(unchangedBookNames.count)")
		}
		if cachedBookNames != ["Symptoms of a Heartbreak", "Tiny Pretty Things"] {
			throw TestErrors.testFailed(message: "cachedBookNames: Expected 2 books, found \(cachedBookNames.count)")
		}
		if updatedBookNames != ["Symptoms of a Heartbreak"] {
			throw TestErrors.testFailed(message: "updatedBookNames: Expected [\"Symptoms of a Heartbreak\"], found \(updatedBookNames)")
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

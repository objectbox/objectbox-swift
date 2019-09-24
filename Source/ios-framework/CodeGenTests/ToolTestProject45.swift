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

    let storeFolder = URL(fileURLWithPath: "/tmp/tooltestDB42/")
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

		let readTinyPrettyThings = try bookBox.get(tinyPrettyThings.id)!
		let unchangedAuthorNames = Array(readTinyPrettyThings.authors).map { $0.name }.sorted()
		tinyPrettyThings.authors.replace([dhonielle])
		try tinyPrettyThings.authors.applyToDb()
		let cachedAuthorNames = Array(readTinyPrettyThings.authors).map { $0.name }.sorted()
		readTinyPrettyThings.authors.reset()
		let updatedAuthorNames = Array(readTinyPrettyThings.authors).map { $0.name }.sorted()
		
		if unchangedAuthorNames != ["Dhonielle Clayton", "Sona Charaipotra"] {
			throw TestErrors.testFailed(message: "unchangedAuthorNames: Expected 2 authors, found \(unchangedAuthorNames.count)")
		}
		if cachedAuthorNames != ["Dhonielle Clayton", "Sona Charaipotra"] {
			throw TestErrors.testFailed(message: "cachedAuthorNames: Expected 2 authors, found \(cachedAuthorNames.count)")
		}
		if updatedAuthorNames != ["Dhonielle Clayton"] {
			throw TestErrors.testFailed(message: "updatedAuthorNames: Expected [\"Dhonielle Clayton\"], found \(updatedAuthorNames)")
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

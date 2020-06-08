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
        let relationEditGroup = DispatchGroup()
        let queue = DispatchQueue(label: "io.objectbox.test.workerQueue", attributes: [.concurrent, .initiallyInactive])
        print("note: Adding Books:")

        let tinyPrettyThings = Book(name: "Tiny Pretty Things")
        let symptomsOfAHeartbreak = Book(name: "Symptoms of a Heartbreak")
        try bookBox.put( [tinyPrettyThings, symptomsOfAHeartbreak] )
        
        let firstNames = ["John", "Jane", "Jeanette", "Jill", "James",
                          "Petra", "Illyana", "Anastasia", "Andrea", "Melanie",
                          "Dhonielle", "Pascale", "Angela", "Denise", "Bill",
                          "Yoshiaki", "Bente", "Vette", "Vicki", "Nora"]
        let lastNames = ["Smith", "Miller", "Baker", "Baxter", "Argyle",
                         "Butler", "Shaw", "Wells", "Frost", "Carter",
                         "Jackson", "Swift", "Cash", "Lister", "Sjøberg",
                         "Nystrom", "Surstromming", "Lyngstad", "Anderson", "Faltskog"]
        var authors = [Author]()
        
        for fIndex in 0..<firstNames.count {
            for lIndex in 0..<lastNames.count {
                let author = Author(name: "\(firstNames[fIndex]) \(lastNames[lIndex])")
                try authorBox.put(author)
                authors.append(author)
                relationEditGroup.enter()
                queue.async {
                    author.books.append(tinyPrettyThings)
                    try! author.books.applyToDb()
                    relationEditGroup.leave()
                }
                relationEditGroup.enter()
                queue.async {
                    author.books.append(symptomsOfAHeartbreak)
                    try! author.books.applyToDb()
                    relationEditGroup.leave()
                }
            }
        }

        queue.activate() // Increase likelihood of concurrency by only now starting the queue.
        relationEditGroup.wait()

        print("note: Testing forward:")

        for author in authors {
            let readAuthor = try authorBox.get(author.id)!
            let bookNames = Array(readAuthor.books).map { $0.name }.sorted()
            
            if bookNames != ["Symptoms of a Heartbreak", "Tiny Pretty Things"] {
                throw TestErrors.testFailed(message: "bookNames: \(readAuthor.name): Expected [\"Symptoms of a Heartbreak\", \"Tiny Pretty Things\"], found \(bookNames)")
            }
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

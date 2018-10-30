//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

class Services {
    static let instance: Services = Services()
    
    let store: Store!
    let authorBox: Box<Author>
    let noteBox: Box<Note>

    private init() {
        self.store = try! Store.createStore()
        self.store.register(entity: Author.self)
        self.store.register(entity: Note.self)

        authorBox = self.store.box(for: Author.self)
        noteBox = self.store.box(for: Note.self)
    }
}

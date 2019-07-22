//  Copyright © 2019 ObjectBox. All rights reserved.

import Foundation

// Used by Box to cache the objects that help it serialize/deserialize objects.
//
// Delegates work to its CursorBase. This is implemented in generated code in Swift
// to hydrate and read entity instances. The flatbuffer is injected into CursorBase method calls
// as the object that implements PropertyCollector and EntityReader to receive the results.

open class SerializationAdapter<CE: EntityInspectable>: NSObject where CE == CE.CursorBaseType.EntityType {
    typealias CursorBaseType = CE.CursorBaseType
    
    internal var flatBuffer = FlatBuffer()
    var cursorBase: CursorBaseType
    private weak var store: Store!

    init(cursorBase: CursorBaseType, store: Store) {
        self.cursorBase = cursorBase
        self.store = store
    }
}

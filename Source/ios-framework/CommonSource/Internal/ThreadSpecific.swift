//  From the Swift-Evolution Property Wrappers proposal:
//  https://github.com/DougGregor/swift-evolution/blob/property-wrappers/proposals/0258-property-wrappers.md

import Foundation

final class ThreadSpecific<T> {
    private var key = pthread_key_t()
    private let initialValue: T
    
    init(key: pthread_key_t, initialValue: T) {
        self.key = key
        self.initialValue = initialValue
    }
    
    init(initialValue: T) {
        self.initialValue = initialValue
        pthread_key_create(&key) {
            // 'Any' erasure due to inability to capture 'self' or <T>
            $0.assumingMemoryBound(to: Any.self).deinitialize(count: 1)
            $0.deallocate()
        }
    }
    
    deinit {
        fatalError("\(ThreadSpecific<T>.self).deinit is unsafe and would leak")
    }
    
    private var box: UnsafeMutablePointer<Any> {
        if let pointer = pthread_getspecific(key) {
            return pointer.assumingMemoryBound(to: Any.self)
        } else {
            let pointer = UnsafeMutablePointer<Any>.allocate(capacity: 1)
            pthread_setspecific(key, UnsafeRawPointer(pointer))
            pointer.initialize(to: initialValue as Any)
            return pointer
        }
    }
    
    var value: T {
        get {
            guard let pointee = box.pointee as? T else { fatalError("ThreadSpecific type inconsistent.") }
            return pointee
        }
        set (newValue) {
            box.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee = newValue }
        }
    }
}

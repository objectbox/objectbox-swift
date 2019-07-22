//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Used by generated Swift code to get properties from an entity to store them.
/// Is injected into the code generator; the actual implementation is in `FlatBufferBuilder`.

public protocol PropertyCollector: class {
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Bool, at propertyOffset: UInt16)
    
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Int8, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Int16, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Int32, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Int64, at propertyOffset: UInt16)
    
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: UInt8, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: UInt16, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: UInt32, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: UInt64, at propertyOffset: UInt16)
    
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Float, at propertyOffset: UInt16)
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ value: Double, at propertyOffset: UInt16)
    
    /// Write a value read from the given entity and write it to the given property.
    func collect(_ date: Date?, at propertyOffset: UInt16)
    
    
    /// - Parameter value: Treated as Int64, effectively ignoring 32bit platforms.
    func collect(_ value: Int, at propertyOffset: UInt16)
    
    /// - Parameter value: Treated as Int64, effectively ignoring 32bit platforms.
    func collect(_ value: UInt, at propertyOffset: UInt16)
    
    /// - Parameter dataOffset: If this is 0, the function does nothing.
    func collect(dataOffset: OBXDataOffset, at propertyOffset: UInt16)
    
    /// - returns: A value > 0 when a string value is prepared; 0 if the property is skipped.
    func prepare(string: String?, at propertyOffset: UInt16) -> OBXDataOffset
    
    /// - returns: A value > 0 when a data value is prepared; 0 if the property is skipped.
    func prepare(bytes data: Data?, at propertyOffset: UInt16) -> OBXDataOffset
    
    /// - returns: A value > 0 when a data value is prepared; 0 if the property is skipped.
    func prepare(bytes: [UInt8]?, at propertyOffset: UInt16) -> OBXDataOffset
}

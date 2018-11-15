//
// Copyright © 2018 ObjectBox Ltd. All rights reserved.
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

// To make code generation easier, provide 1 method name with many overloads.
public extension ObjectBox.EntityReader {

    func read(at index: UInt16) -> Bool {
        return self.boolean(at: index)
    }

    func read(at index: UInt16) -> Int8 {
        return self.int8(at: index)
    }

    func read(at index: UInt16) -> Int16 {
        return self.int16(at: index)
    }

    func read(at index: UInt16) -> Int32 {
        return self.int32(at: index)
    }

    func read(at index: UInt16) -> Int64 {
        return self.int64(at: index)
    }

    // TODO: conditionally compile to Int64/Int32?
    func read(at index: UInt16) -> Int {
        return self.integer(at: index)
    }

    func read(at index: UInt16) -> Float {
        return self.float(at: index)
    }

    func read(at index: UInt16) -> Double {
        return self.double(at: index)
    }

    func read(at index: UInt16) -> Date {
        return self.date(at: index)!
    }

    func read(at index: UInt16) -> String {
        return self.string(at: index)!
    }

    func read(at index: UInt16) -> Data {
        return self.bytes(at: index)!
    }

    func read<E>(at index: UInt16) -> Id<E> where E: Store.InspectableEntity {
        return Id<E>(entityId(at: index))
    }

    func read<T>(at index: UInt16, store: Store) -> ToOne<T> where T: Store.InspectableEntity {
        let entityId: Id<T> = read(at: index)
        let entityBox = store.box(for: T.self)
        return ToOne<T>(box: entityBox, id: entityId)
    }

    // MARK: Optional properties

    func read(at index: UInt16) -> Bool? {
        return self.__optionalBool(atPropertyOffset: index)?.boolValue
    }

    func read(at index: UInt16) -> Int8? {
        return self.__optionalInt8(atPropertyOffset: index)?.int8Value
    }

    func read(at index: UInt16) -> Int16? {
        return self.__optionalInt16(atPropertyOffset: index)?.int16Value
    }

    func read(at index: UInt16) -> Int32? {
        return self.__optionalInt32(atPropertyOffset: index)?.int32Value
    }

    func read(at index: UInt16) -> Int64? {
        return self.__optionalInt64(atPropertyOffset: index)?.int64Value
    }

    func read(at index: UInt16) -> Float? {
        return self.__optionalFloat(atPropertyOffset: index)?.floatValue
    }

    func read(at index: UInt16) -> Double? {
        return self.__optionalDouble(atPropertyOffset: index)?.doubleValue
    }

    func read(at index: UInt16) -> Int? {
        return self.__optionalInteger(atPropertyOffset: index)?.intValue
    }

    func read(at index: UInt16) -> UInt? {
        return self.__optionalUnsignedInteger(atPropertyOffset: index)?.uintValue
    }

    func read(at index: UInt16) -> Date? {
        return self.date(at: index)
    }

    func read(at index: UInt16) -> String? {
        return self.string(at: index)
    }

    func read(at index: UInt16) -> Data? {
        return self.bytes(at: index)
    }
}

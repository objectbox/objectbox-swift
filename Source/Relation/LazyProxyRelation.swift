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

// swiftlint:disable identifier_name
internal class LazyProxyRelation<Target>
where Target: Store.InspectableEntity {

    internal let box: Box<Target>?

    internal var hasValue: Bool {
        switch _state {
        case .none:
            return false
        default:
            return true
        }
    }

    internal enum State {
        /// NULL reference
        case none
        /// Set by app developer, but not stored
        case unstored(entity: Target)
        /// Initial state before attempting a lazy load
        case lazy(id: Id<Target>)
        /// Known reference established in the database
        case stored(id: Id<Target>, entity: Target)
        case unresolvable(id: Id<Target>)

        internal var entity: Target? {
            switch self {
            case .none,
                 .lazy,
                 .unresolvable:
                return nil
            case .unstored(let entity),
                 .stored(_, let entity):
                return entity
            }
        }

        internal var entityId: Id<Target>? {
            switch self {
            case .none:
                return nil
            case .unstored(entity: let entity):
//                fatalError()
                return nil
            case .lazy(id: let entityId),
                 .stored(id: let entityId, entity: _),
                 .unresolvable(id: let entityId):
                return entityId
            }
        }

        internal enum Initial {
            case none
            case lazy(id: Id<Target>)
            case unstored(entity: Target)
            case stored(id: Id<Target>, entity: Target)

            internal init(entity: Target?) {
                switch entity {
                case .some(let entity):
                    self = .unstored(entity: entity)
                case .none:
                    self = .none
                }
            }

            internal init(id: Id<Target>) {
                if id.needsIdGeneration {
                    self = .none
                } else {
                    self = .lazy(id: id)
                }
            }
        }

        internal init(initial: Initial) {
            switch initial {
            case .none: self = .none
            case .lazy(let id): self = .lazy(id: id)
            case .unstored(let entity): self = .unstored(entity: entity)
            case .stored(let id, let entity): self = .stored(id: id, entity: entity)
            }
        }

        internal init(target: Target?) {
            guard let entity = target else {
                self = .none
                return
            }

            if entity._id.needsIdGeneration {
                self = .unstored(entity: entity)
            } else {
                //swiftlint:disable force_cast
                self = .stored(id: entity._id as! Id<Target>, entity: entity)
                //swiftlint:enable force_cast
            }
        }

        internal init(targetId: Id<Target>?) {
            switch targetId {
            case .none:
                self = .none
            case .some(let targetId):
                self = .lazy(id: targetId)
            }
        }

        internal func loaded(box: Box<Target>?) -> State {
            guard case .lazy(let id) = self else { return self }
            guard let box = box else { return self }
            guard let entity = box.get(id) else { return .unresolvable(id: id) }
            return .stored(id: id, entity: entity)
        }
    }

    private var _state: State
    internal var target: Target? {
        get {
            _state = _state.loaded(box: box)
            return _state.entity
        }

        set {
            _state = State(target: newValue)
        }
    }

    internal var targetId: Id<Target>? {
        get {
            return _state.entityId
        }
        set {
            _state = State(targetId: newValue)
        }
    }

    internal init(box: Box<Target>?, initialState: State.Initial) {
        self.box = box
        self._state = State(initial: initialState)
    }
}

extension LazyProxyRelation: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self._state {
        case .none:
            return ".none"
        case .unstored(entity: let target):
            return ".unstored(target: \(target))"
        case .stored(id: let id, entity: let entity):
            return ".stored(id: \(id), target: \(entity))"
        case .lazy(id: let id):
            return ".lazy(id: \(id))"
        case .unresolvable(id: let id):
            return ".unresolvable(id: \(id))"
        }
    }
}
// swiftlint:enable identifier_name

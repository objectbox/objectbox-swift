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
internal class LazyProxyRelation<Target: EntityInspectable & __EntityRelatable>
where Target == Target.EntityBindingType.EntityType {

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
        case lazy(id: EntityId<Target>)
        /// Known reference established in the database
        case stored(id: EntityId<Target>, entity: Target)
        case unresolvable(id: EntityId<Target>)

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

        internal var entityId: EntityId<Target>? {
            switch self {
            case .none:
                return nil
            case .unstored(entity: _):
//                fatalError()
                return nil
            case .lazy(id: let entityId),
                 .stored(id: let entityId, entity: _),
                 .unresolvable(id: let entityId):
                return entityId
            }
        }

        internal init(initial: InitialState) {
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
                self = .stored(id: entity._id as! EntityId<Target>, entity: entity)
                //swiftlint:enable force_cast
            }
        }

        internal init(targetId: EntityId<Target>?) {
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
            guard let entity = try? box.get(id) else { return .unresolvable(id: id) }
            return .stored(id: id, entity: entity)
        }
    }
    
    internal enum InitialState {
        case none
        case lazy(id: EntityId<Target>)
        case unstored(entity: Target)
        case stored(id: EntityId<Target>, entity: Target)
        
        internal init(entity: Target?) {
            switch entity {
            case .some(let entity):
                self = .unstored(entity: entity)
            case .none:
                self = .none
            }
        }
        
        internal init(id: EntityId<Target>) {
            if id.needsIdGeneration {
                self = .none
            } else {
                self = .lazy(id: id)
            }
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

    internal var targetId: EntityId<Target>? {
        get {
            return _state.entityId
        }
        set {
            _state = State(targetId: newValue)
        }
    }

    internal init(box: Box<Target>?, initialState: InitialState) {
        self.box = box
        self._state = State(initial: initialState)
    }

    internal init(box: Box<Target>?, original: LazyProxyRelation<Target>) {
        self.box = box
        self._state = original._state
    }
    
    /// Reset the cached target in this relation. If you have changed the target
    /// of this relation to a not-yet-stored object, this will be a no-op.
    /// Call get() to reset the actual relation to its previous on-disk state.
    func reset() {
        switch _state {
        case .stored(let id, _):
            _state = .lazy(id: id)
        case .unresolvable(let id):
            _state = .lazy(id: id)
        case .unstored(entity: let target):
            let entityId = Target.entityBinding.entityId(of: target)
            if entityId != 0 {
                _state = .lazy(id: EntityId<Target>(entityId))
            }
        default:
            break
        }
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

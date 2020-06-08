/// Different from regular `Property`s, backlinks and standalone relations don't actually exist in the database,
/// so to allow referencing them when creating a relation query using `link(_ property:)`, they use their own class.
///
/// You usually do not create instances of this struct. The code generator creates them for you and you just use them
/// in property queries to refer to individual properties.
public struct ToManyProperty<R> {
    /// Type of the referenced entity.
    typealias ReferencedType = R

    /// Type of ToMany you are describing, plus requisite schema ID so it can be found in the model.
    /// Used by the code generator to set up a `ToManyProperty` with the right type and information.
    public enum ToManyId {
        /// ToOne backlink. Property ID on ValueType.
        case valuePropertyId(obx_schema_id)
        /// Standalone ToMany. Relation ID on OwningType.
        case relationId(obx_schema_id)
        /// Standalone ToMany backlink. Relation ID is on ValueType, not OwningType.
        case backlinkRelationId(obx_schema_id)
    }

    internal let toManyId: ToManyId

    /// :nodoc:
    public init(_ toManyId: ToManyId) {
        self.toManyId = toManyId
    }
}

// This file must be added to the project when using Jazzy to generate documentation.
// Remove it again afterwards.

public extension Store {
    /// A store with a fully configured model. This method is created by the code generator with your model's metadata
    /// in place.
    ///
    /// - Parameter directoryPath: The path to the directory in which ObjectBox should store database files.
    /// - Parameter maxDbSizeInKByte: Maximum size the database may take up on disk (default: 1 GiB).
    /// - Parameter fileMode: The unix permissions (like 0o755) to use for creating the database files.
    /// - Parameter maxReaders: "readers" are a finite resource for which you need to define a maximum upfront. The
    ///                         default value is enough for most apps and usually you can ignore it completely. However,
    ///                         if you get the "maxReadersExceeded" error, you should verify your threading. For each
    ///                         thread, ObjectBox uses multiple readers. Their number (per thread) depends on number of
    ///                         types, relations, and usage patterns. Thus, if you are working with many threads (e.g.
    ///                         server-like scenario), it can make sense to increase the maximum number of readers. The
    ///                         default value 0 (zero) lets ObjectBox choose an internal default (currently around 120).
    ///                         So if you hit this limit, try values around 200-500.
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    public convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024, fileMode: UInt32 = 0o755,
                            maxReaders: UInt32 = 0) throws {
        try self.init(
            model: OpaquePointer(bitPattern: 0)!,
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders)
    }
}

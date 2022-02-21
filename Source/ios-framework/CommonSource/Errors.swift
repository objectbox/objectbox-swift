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

/// Error codes thrown by ObjectBox APIs.
public enum ObjectBoxError: Swift.Error {
    /// Unexpected obx_err propagated from C core to Swift.
    case unknown(code: Int32, message: String)
    /// Attempt to open a write transaction nested in a read-only transaction.
    case cannotWriteWhileReading(message: String)
    /// Asked to put an entity/property change that would cause a unique property to be present twice.
    case uniqueViolation(message: String)
    /// Asked to obtain an entity that does not exist (e.g. nonexistent ID, no query results).
    case notFound(message: String)
    /// Thrown when a request does not make sense in the current state. For example, doing actions on a closed object.
    case illegalState(message: String)
    /// Nonsense value given to an API call.
    case illegalArgument(message: String)
    /// Thrown when a resource could not be allocated.
    case allocation(message: String)
    /// An unexpected error.
    case noErrorInfo(message: String)
    /// An unexpected error.
    case general(message: String)
    /// Size limit given when database was opened was exceeded.
    case dbFull(message: String)
    /// The limit on the number of simultaneous read transactions specified when creating the Store has been exceeded.
    case maxReadersExceeded(message: String)
    /// Can not continue, the Store must be closed.
    case storeMustShutdown(message: String)
    /// A general storage-related error.
    case storageGeneral(message: String)
    /// User asked for a unique result, database contains several matches.
    case nonUniqueResult(message: String)
    /// Property requested with a type incompatible with what is actually in the database.
    case propertyTypeMismatch(message: String)
    /// A constraint specified on a database field has been violated.
    case constraintViolated(message: String)
    /// An illegal argument bubbled up into the C++ core.
    case stdIllegalArgument(message: String)
    /// A range exceeds what is actually present internally.
    case stdOutOfRange(message: String)
    /// A length limit has been exceeded.
    case stdLength(message: String)
    /// Memory error (asking for a huge amount by accident?).
    case stdBadAlloc(message: String)
    /// A floating point value has exceeded its defined range.
    case stdRange(message: String)
    /// An integral value has exceeded its defined range.
    case stdOverflow(message: String)
    /// An unexpected error occurred in the C++ core.
    case stdOther(message: String)
    /// The database schema does not match. (Is there a problem with your model.json?)
    case schema(message: String)
    /// DB file has errors, e.g. illegal values or structural inconsistencies were detected.
    case fileCorrupt(message: String)
    /// DB file has errors related to pages, e.g. bad page refs outside of the file.
    case filePagesCorrupt(message: String)
    /// Attempted to establish a relation to an entity that hasn't been assigned an ID yet.
    case cannotRelateToUnsavedEntities(message: String)

    /// Typically when there's no open store available at the given directory
    case cannotAttachToStore(message: String)

    /// Unexpected error, should never occur in practice, but for pragmatic reasons, we cover the case.
    /// Used in some cases where ObjectBox e.g. calls a function (which can only say throws and not what it throws)
    /// If you encounter this error in your use of ObjectBox, please report it to us, as it's likely a bug in the
    /// binding.
    case unexpected(error: Error)

    /// An error related to sync
    case sync(message: String)

}

/// Check whether obx_last_error_code() contains an error, and if yes, throw that as a Swift error, together with the
/// text from obx_last_error_message(). Note that C API functions with a void return do not give errors. Call this only
/// for C API functions with a return value, or call checkLastError(error:) for C API functions that return obx_err.
/// Clears ObjectBox's last error in case of error, so future calls to ObjectBox don't seem to be throwing an error that
/// hasn't been handled yet.
internal func checkLastError() throws {
    try checkLastError(obx_last_error_code())
}

/// Check whether the given error code that was just returned by an obx_xxx call indicates an error, and if yes, throw
/// that as a Swift error, together with the text from obx_last_error_message(). Note that C API functions with a void
/// return do not give errors. Call this only for C API functions with a return value, or call checkLastError(error:)
/// for C API functions that return obx_err.
/// Clears ObjectBox's last error in case of error, so future calls to ObjectBox don't seem to be throwing
/// an error that hasn't been handled yet.
internal func checkLastError(_ error: obx_err) throws {
    if error == OBX_SUCCESS { return }
    let message = String(utf8String: obx_last_error_message()) ?? ""
    if error != OBX_NOT_FOUND {
        // In case the error is not catched, info might be lost; so better print it now(?), or is there a better way?
        print("Error occurred: \(message) (\(error))")
    }
    obx_last_error_clear()
    try throwObxErr(error, message: message)
}

internal func checkLastErrorSuccessFlag(_ error: obx_err) throws -> Bool {
    if error == OBX_SUCCESS {
        return true
    } else if error == OBX_NO_SUCCESS {
        return false
    } else {
        try checkLastError(error)  // Should always throw at this point
        return false
    }
}

/// E.g. prints error
func checkLastErrorNoThrow(_ error: obx_err) {
    if error == OBX_SUCCESS { return }
    let message = String(utf8String: obx_last_error_message()) ?? ""
    if error != OBX_NOT_FOUND {
        // In case the error is not catched, info might be lost; so better print it now(?), or is there a better way?
        print("Error occurred: \(message) (\(error))")
    }
    obx_last_error_clear()
}

/// Reserved for "wrong usages" by the user that the compiler cannot detect (try/catch otherwise).
internal func failFatallyIfError() {
    checkFatalError(obx_last_error_code())
}

/// Reserved for "wrong usages" by the user that the compiler cannot detect (try/catch otherwise).
internal func fatalErrorWithStack(_ message: String) -> Never {
    for symbol in Thread.callStackSymbols {
        // Print the stack trace without the "unexciting" symbols
        if !symbol.contains("XCTest") && !symbol.contains("xctest") && !symbol.contains("CoreFoundation")
                   && !symbol.contains("checkFatalError") && !symbol.contains("failFatallyIfError") {
            print(symbol)
        }
    }
    fatalError(message)
}

/// Reserved for "wrong usages" by the user that the compiler cannot detect (try/catch otherwise).
internal func checkFatalError(_ err: obx_err) {
    if err != OBX_SUCCESS {
        let message = String(utf8String: obx_last_error_message()) ?? "Unknown"
        fatalErrorWithStack("\(message) (\(err))")
    }
}

/// Throw the given error code and optional string as an error message, if the code given didn't indicate success.
internal func check(error: obx_err, message: String = "") throws {
    if error != OBX_SUCCESS {
        try throwObxErr(error, message: message)
    }
}

internal func checkCResult(_ cResultCode: obx_err, message: String = "") throws {
    try check(error: cResultCode, message: message)
}

/// Ignore and log the given Swift error.
internal func ignoreAndLog(error: Error) {
    switch error {
    case ObjectBoxError.unknown(let code, let message):
        print("Error: Unknown ObjectBox error '\(message)' (\(code))")
    default:
        print("Error: \(error).")
    }
}

// swiftlint:disable cyclomatic_complexity function_body_length
/// Throw the given error code as a Swift error. Note this doesn't check whether err is OBX_SUCCESS.
/// This method always throws and never returns.
internal func throwObxErr(_ err: obx_err, message: String = "") throws -> Never {
    switch err {
        /// Returned by e.g. get operations if nothing was found for a specific ID.
    /// This is NOT an error condition, and thus no last error info is set.
    case OBX_NOT_FOUND:
        throw ObjectBoxError.notFound(message: message)

    // General errors
    case OBX_ERROR_ILLEGAL_STATE:
        if message.hasPrefix("Cannot start a write transaction inside a read only transaction") {
            throw ObjectBoxError.cannotWriteWhileReading(message: message)
        } else {
            throw ObjectBoxError.illegalState(message: message)
        }
    case OBX_ERROR_ILLEGAL_ARGUMENT:
        throw ObjectBoxError.illegalArgument(message: message)
    case OBX_ERROR_ALLOCATION:
        throw ObjectBoxError.allocation(message: message)
    case OBX_ERROR_NO_ERROR_INFO:
        throw ObjectBoxError.noErrorInfo(message: message)
    case OBX_ERROR_GENERAL:
        throw ObjectBoxError.general(message: message)
    case OBX_ERROR_UNKNOWN:
        throw ObjectBoxError.unknown(code: OBX_ERROR_UNKNOWN, message: message)

    // Storage errors (often have a secondary error code)
    case OBX_ERROR_DB_FULL:
        throw ObjectBoxError.dbFull(message: message)
    case OBX_ERROR_MAX_READERS_EXCEEDED:
        throw ObjectBoxError.maxReadersExceeded(message: message)
    case OBX_ERROR_STORE_MUST_SHUTDOWN:
        throw ObjectBoxError.storeMustShutdown(message: message)
    case OBX_ERROR_STORAGE_GENERAL:
        #if os(macOS) // Only macOS needs an App Group to do its mutexes, iOS uses a different mutex.
        if message.hasPrefix("Could not open env for DB") { // Error reported from obx_store_open().
            throw ObjectBoxError.storageGeneral(message: message + " - did you perhaps forget to set up an "
                    + "\"App Group\" Capability in your target settings?")
        }
        #endif
        throw ObjectBoxError.storageGeneral(message: message)
    // Data errors
    case OBX_ERROR_UNIQUE_VIOLATED:
        throw ObjectBoxError.uniqueViolation(message: message)
    case OBX_ERROR_NON_UNIQUE_RESULT:
        throw ObjectBoxError.nonUniqueResult(message: message)
    case OBX_ERROR_PROPERTY_TYPE_MISMATCH:
        throw ObjectBoxError.propertyTypeMismatch(message: message)
    case OBX_ERROR_CONSTRAINT_VIOLATED:
        throw ObjectBoxError.constraintViolated(message: message)

    // STD errors
    case OBX_ERROR_STD_ILLEGAL_ARGUMENT:
        throw ObjectBoxError.illegalArgument(message: message)
    case OBX_ERROR_STD_OUT_OF_RANGE:
        throw ObjectBoxError.stdOutOfRange(message: message)
    case OBX_ERROR_STD_LENGTH:
        throw ObjectBoxError.stdLength(message: message)
    case OBX_ERROR_STD_BAD_ALLOC:
        throw ObjectBoxError.stdBadAlloc(message: message)
    case OBX_ERROR_STD_RANGE:
        throw ObjectBoxError.stdRange(message: message)
    case OBX_ERROR_STD_OVERFLOW:
        throw ObjectBoxError.stdOverflow(message: message)
    case OBX_ERROR_STD_OTHER:
        throw ObjectBoxError.stdOther(message: message)

    // Inconsistencies detected
    case OBX_ERROR_SCHEMA:
        throw ObjectBoxError.schema(message: message)
    case OBX_ERROR_FILE_CORRUPT:
        throw ObjectBoxError.fileCorrupt(message: message)
    case OBX_ERROR_FILE_PAGES_CORRUPT:
        throw ObjectBoxError.filePagesCorrupt(message: message)

    case 2: // testStorageException receives this code for a Store on a nonexistent file path.
        throw ObjectBoxError.storageGeneral(message: message.isEmpty ? "Storage error \(err)" : message)

    default:
        throw ObjectBoxError.unknown(code: err, message: message)
    }
}

// swiftlint:enable cyclomatic_complexity function_body_length

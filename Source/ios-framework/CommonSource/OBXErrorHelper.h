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

/*
 We deal with 3 types of exceptions:
 1. C++ exceptions from our C++ flatbuffers code (which Swift or ObjC don't really account for,
    so need to be caught and converted where we make the C++ calls).
 2. Swift "exceptions" (actually NSError** return parameters), which a Swift (or Objective-C)
    program can "catch" and recover from.
 3. Objective-C exceptions. These are basically a C++ exception under the hood, but are intended
    only for use for programming errors. Throwing Objective-C exceptions through AppKit or UIKit
    API can lead to memory leaks and instability. If a function called by Swift receives an
    Objective-C exception, Swift terminates the application.
 */

#import <Foundation/Foundation.h>

#if __cplusplus
extern "C" {
#endif

/// Re-throws all C++ errors as fatal ObjC exceptions.
/// Convenience method for runWithExceptionHandling(NULL, ...).
void runRethrowingExceptions(void (NS_NOESCAPE ^ _Nonnull block)(void));

/// Catches and ignores all recoverable C++ exceptions thrown, re-throws unrecoverable ones as fatal Objective-C
/// exceptions. Convenience method for runWithExceptionHandling(&dummyErr, ...) that just ignores dummyErr.
void runRethrowingOnlyFatalExceptions(void (NS_NOESCAPE ^ _Nonnull block)(void));

/// Rethrows fatal C++ exceptions as Objective-C exceptions, returns the rest as recoverable
///  NSErrors unless error is NULL, in which case they also become fatal Objective-C exceptions.
BOOL runWithExceptionHandling(NSError * _Nullable __autoreleasing * _Nullable error, void (NS_NOESCAPE ^ _Nonnull block)(void))
     __attribute__((swift_error(zero_result)));

/// Catches Objective-C exceptions and returns them. Also forwards Swift errors. Used to guarantee cleanup of our global
/// state (and running of defer statements) in Swift code no matter how a transaction is exited.
/// You can re-throw Objective-C exceptions from Swift by calling their raise method.
NSException* _Nullable catchFatalErrors(NSError * _Nullable __autoreleasing * _Nullable outError,
                                        void (NS_NOESCAPE ^ _Nonnull block)(NSError * _Nullable __autoreleasing * _Nullable error))
                                        __attribute__((swift_error(nonnull_error)));

/// Checks obx_last_error_code() and obx_last_error_message() whether they represent a fatal error, and if they do,
/// throws a (fatal) ObjC exception describing them.
void throwLastFatalError(void);

/// Convert an obx_err error code (and optional message) into an NSError that can be caught as a Swift ObjectBoxError by
/// Swift code. Preferentially use this instead of manually creating NSErrors.
/// Prototype for a method in Errors.swift, exposed to C via @_cdecl:
NSError * _Nullable OBXErrorToNSError(int /* obx_err */ errCode, const char* _Nonnull msg);

#if __cplusplus
}
#endif

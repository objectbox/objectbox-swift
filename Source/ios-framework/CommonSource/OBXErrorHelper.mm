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

#import "OBXErrorHelper.h"
#import "Constants.h"
#include <stdexcept>
#import "ObjectBoxC.h"


extern "C" void runRethrowingExceptions(void (NS_NOESCAPE ^ _Nonnull block)()) {
    runWithExceptionHandling(nil, block);
}

extern "C" void runRethrowingOnlyFatalExceptions(void (NS_NOESCAPE ^ _Nonnull block)()) {
    NSError *err = nil;
    runWithExceptionHandling(&err, block);
}

/// `@throws` an exception even for recoverable errors unless `outErr` is provided.
extern "C" BOOL runWithExceptionHandling(NSError * _Nullable __autoreleasing * _Nullable outErr, void (NS_NOESCAPE ^ _Nonnull block)()) {
    try {
        block();
        return YES;
    } catch (const std::range_error& stdEx) {
        @throw [NSException exceptionWithName:@"STD range error exception exception"
                                       reason:@(stdEx.what())
                                     userInfo:nil];
    } catch (const std::exception& stdEx) {
        @throw [NSException exceptionWithName:@"Unhandled ObjectBox C++ Exception"
                                       reason:@(stdEx.what())
                                     userInfo:nil];
    } catch (NSException *exe) {
        @throw exe;
    } catch (...) {
        @throw [NSException exceptionWithName:@"Unhandled ObjectBox C++ Exception"
                                       reason:@"Unknown (catch-all)"
                                     userInfo:nil];
    }
    return NO;
}


extern "C" NSException* _Nullable catchFatalErrors(NSError * _Nullable __autoreleasing * _Nullable outError, void (NS_NOESCAPE ^ _Nonnull block)(NSError * _Nullable __autoreleasing * _Nullable error)) {
    @try {
        block(outError);
        return nil;
    } @catch(NSException * exception) {
        return exception;
    }
}

extern "C" void throwLastFatalError() {
    obx_err err = obx_last_error_code();
    if (err == OBX_SUCCESS) {
        return;
    }
    
    NSString * reason = obx_last_error_message() ? [NSString stringWithUTF8String: obx_last_error_message()] : nil;
    obx_last_error_clear();
    switch (err) {
        case OBX_ERROR_ILLEGAL_STATE:
            @throw [NSException exceptionWithName:@"IllegalStateException"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_ILLEGAL_ARGUMENT:
            @throw [NSException exceptionWithName:@"IllegalArgumentException"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_MAX_READERS_EXCEEDED:
            @throw [NSException exceptionWithName:@"DbMaxReadersExceededException"
                                           reason:[NSString stringWithFormat:@"Max parallel reads reached. Configure in Store initialization and check your threads. (%@)", reason]
                                         userInfo:nil];
            break;
            
        // STD errors
        case OBX_ERROR_STD_ILLEGAL_ARGUMENT:
            @throw [NSException exceptionWithName:@"STD invalid argument exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_OUT_OF_RANGE:
            @throw [NSException exceptionWithName:@"STD range error exception exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_LENGTH:
            @throw [NSException exceptionWithName:@"STD length error exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_BAD_ALLOC:
            @throw [NSException exceptionWithName:@"STD bad allocation exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_RANGE:
            @throw [NSException exceptionWithName:@"STD out of range exception exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_OVERFLOW:
            @throw [NSException exceptionWithName:@"STD overflow exception exception"
                                           reason:reason
                                         userInfo:nil];
            break;
        case OBX_ERROR_STD_OTHER:
            @throw [NSException exceptionWithName:@"Unhandled ObjectBox C++ Exception"
                                           reason:reason
                                         userInfo:nil];
            break;
            
        default:
#if DEBUG
            NSLog(@"Ignoring non-fatal error %d \"%@\".", err, reason);
#endif
            break;
    }
}

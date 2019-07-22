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

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(uint32_t, OBXEntityQueryFlag) {
    // == Copied from OBXQueryFlags so it can be used better from Swift:
    OBXEntityQueryFlagDistinctCaseSensitive = 32,
    OBXEntityQueryFlagDistinctCaseInsensitive = 64,
} NS_SWIFT_NAME(EntityQueryFlag);


typedef NS_ENUM(uint32_t, OBXEntityPropertyType) {
    OBXEntityPropertyTypeUnknown = 0,
    OBXEntityPropertyTypeBool = 1,
    OBXEntityPropertyTypeByte = 2,
    OBXEntityPropertyTypeShort = 3,
    OBXEntityPropertyTypeChar = 4,
    OBXEntityPropertyTypeInt = 5,
    OBXEntityPropertyTypeLong = 6,
    OBXEntityPropertyTypeFloat = 7,
    OBXEntityPropertyTypeDouble = 8,
    OBXEntityPropertyTypeString = 9,
    /// Internally stored as a int64_t
    OBXEntityPropertyTypeDate = 10,
    /// Relation to another entity
    OBXEntityPropertyTypeRelation = 11,
    OBXEntityPropertyTypeReserved1 = 12,
    OBXEntityPropertyTypeReserved2 = 13,
    OBXEntityPropertyTypeReserved3 = 14,
    OBXEntityPropertyTypeReserved4 = 15,
    OBXEntityPropertyTypeReserved5 = 16,
    OBXEntityPropertyTypeReserved6 = 17,
    OBXEntityPropertyTypeReserved7 = 18,
    OBXEntityPropertyTypeReserved8 = 19,
    OBXEntityPropertyTypeReserved9 = 20,
    OBXEntityPropertyTypeReserved10 = 21,
    OBXEntityPropertyTypeBoolVector = 22,
    OBXEntityPropertyTypeByteVector = 23,
//    OBXEntityPropertyTypeShortVector = 24,
//    OBXEntityPropertyTypeCharVector = 25,
//    OBXEntityPropertyTypeIntVector = 26,
//    OBXEntityPropertyTypeLongVector = 27,
//    OBXEntityPropertyTypeFloatVector = 28,
//    OBXEntityPropertyTypeDoubleVector = 29,
//    OBXEntityPropertyTypeStringVector = 30,
//    OBXEntityPropertyTypeDateVector = 31
} NS_SWIFT_NAME(EntityPropertyType);

typedef NS_OPTIONS(NSUInteger, OBXEntityPropertyFlag) {
    /// One long property on an entity must be the ID
    OBXEntityPropertyFlagId = 1,
    /// On languages like Java, a non-primitive type is used (aka wrapper types, allowing null)
    OBXEntityPropertyFlagNonPrimitiveType = 2,
    /// Unused yet
    OBXEntityPropertyFlagNotNull = 4,
    OBXEntityPropertyFlagIndexed = 8,
    /// Unused yet
    OBXEntityPropertyFlagReserved = 16,
    /// Unused yet: Unique index
    OBXEntityPropertyFlagUnique = 32,
    /// Unused yet: Use a persisted sequence to enforce ID to rise monotonic (no ID reuse)
    OBXEntityPropertyFlagIdMonotonicSequence = 64,
    /// Allow IDs to be assigned by the developer
    OBXEntityPropertyFlagIdSelfAssignable = 128,
    /// Unused yet
    OBXEntityPropertyFlagIndexPartialSkipNull = 256,
    /// Unused yet, used by References for 1) back-references and 2) to clear references to deleted objects (required for ID reuse)
    OBXEntityPropertyFlagIndexPartialSkipZero = 512,
    /// Virtual properties may not have a dedicated field in their entity class, e.g. target IDs of to-one relations
    OBXEntityPropertyFlagVirtual = 1024,
    /// Index uses a 32 bit hash instead of the value
    /// (32 bits is shorter on disk, runs well on 32 bit systems, and should be OK even with a few collisions)
    OBXEntityPropertyFlagIndexHash = 2048,
    /// Index uses a 64 bit hash instead of the value
    /// (recommended mostly for 64 bit machines with values longer >200 bytes; small values are faster with a 32 bit hash)
    OBXEntityPropertyFlagIndexHash64 = 4096,
    
    OBXEntityPropertyFlagUnsigned = 8192,

    //    OBXEntityPropertyFlagNone = 0, // Implicit in Objective-C
    OBXEntityPropertyFlagAll = 8191
} NS_SWIFT_NAME(EntityPropertyFlag);


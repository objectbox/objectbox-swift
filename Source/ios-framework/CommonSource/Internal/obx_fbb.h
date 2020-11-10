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

#include "objectbox-c.h"
#include <stdint.h>

#if __cplusplus
extern "C" {
#endif

#pragma mark Data Types
    
/// C wrapper around the parts of the FlatbufferBuilder C++ library that clients of ObjectBox need. Allows writing flatbuffers. Obtain one using obx_fbb_create().
struct OBX_fbb;
    
/// Pointer into flatbuffer data that you want to read from. Obtain one from obx_fbr_get_root().
struct OBX_fbr;

    
/// Wrapper for `flatbuffers::Offset<flatbuffers::String>` that enables exposing
/// the collector interface to C/Swift.
typedef uint32_t OBXDataOffset;


#pragma mark - Writing
    
/// Create a FlatBuffer builder object ready for reading or writing.
struct OBX_fbb* _Nonnull obx_fbb_create();

/// Dispose of the memory used by a FlatBuffer builder created using obx_fbb_create() once you are done with it.
void obx_fbb_free(struct OBX_fbb* _Nonnull self);

/// @param self the flatbuffer to complete and whose data you want returned.
/// @param outBytes A buffer referencing the built FlatBuffer data. This buffer is owned by the flatbuffer, do not free it!
void obx_fbb_finish(struct OBX_fbb* _Nonnull self, struct OBX_bytes * _Nonnull outBytes);

bool obx_fbb_is_collecting(struct OBX_fbb* _Nonnull self);
void obx_fbb_set_collecting(struct OBX_fbb* _Nonnull self, bool state);

/* Handle NULL values by just not collecting a property. */

/// Query whether collection has already started.
bool obx_fbb_did_start(struct OBX_fbb* _Nonnull self);

/// Start the collection, if not already started.
void obx_fbb_ensure_started(struct OBX_fbb* _Nonnull self);

void obx_fbb_clear(struct OBX_fbb* _Nonnull self);

/* Handle NULL values by just not collecting a property. */
void obx_fbb_collect_bool(struct OBX_fbb* _Nonnull self, bool value, uint16_t propertyOffset);

void obx_fbb_collect_int8(struct OBX_fbb* _Nonnull self, int8_t value, uint16_t propertyOffset);
void obx_fbb_collect_int16(struct OBX_fbb* _Nonnull self, int16_t value, uint16_t propertyOffset);
void obx_fbb_collect_int32(struct OBX_fbb* _Nonnull self, int32_t value, uint16_t propertyOffset);
void obx_fbb_collect_int64(struct OBX_fbb* _Nonnull self, int64_t value, uint16_t propertyOffset);

void obx_fbb_collect_uint8(struct OBX_fbb* _Nonnull self, uint8_t value, uint16_t propertyOffset);
void obx_fbb_collect_uint16(struct OBX_fbb* _Nonnull self, uint16_t value, uint16_t propertyOffset);
void obx_fbb_collect_uint32(struct OBX_fbb* _Nonnull self, uint32_t value, uint16_t propertyOffset);
void obx_fbb_collect_uint64(struct OBX_fbb* _Nonnull self, uint64_t value, uint16_t propertyOffset);

void obx_fbb_collect_float(struct OBX_fbb* _Nonnull self, float value, uint16_t propertyOffset);
void obx_fbb_collect_double(struct OBX_fbb* _Nonnull self, double value, uint16_t propertyOffset);

void obx_fbb_collect_data_offset(struct OBX_fbb* _Nonnull self, OBXDataOffset dataOffset, uint16_t propertyOffset);

OBXDataOffset obx_fbb_prepare_string(struct OBX_fbb* _Nonnull self, const char* _Nonnull string);
OBXDataOffset obx_fbb_prepare_bytes(struct OBX_fbb* _Nonnull self, const void* _Nonnull bytes, size_t size);

#pragma mark - Reading

/// Obtains a Flatbuffer root pointer for use with the other obx_fbr calls.
/// Do not free an OBX_fbr, it is just a pointer into an interesting location of the raw data passed in.
/// @param bytes the raw flatbuffers data as returned from ObjectBox calls like obx_box_get(). This data is referenced, do not free until you're done using the reader.
const struct OBX_fbr* _Nonnull obx_fbr_get_root(const void* _Nonnull bytes);

/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_bool(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, bool* _Nonnull result);

/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_int8(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int8_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_int16(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int16_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_int32(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int32_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_int64(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int64_t* _Nonnull result);

/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_uint8(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint8_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_uint16(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint16_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_uint32(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint32_t* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_uint64(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint64_t* _Nonnull result);

/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_float(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, float* _Nonnull result);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param result the value read.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_double(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, double* _Nonnull result);

/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @return a pointer to an internal buffer holding the string read, or NULL if it was a NULL value. Do not free the returned string, copy it to keep it around.
const char * _Nullable obx_fbr_read_string(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset);
/// @param self the OBX_fbr from which you want to read.
/// @param propertyOffset the offset of the offset to the actual data.
/// @param outBytes This struct is set to the pointer and size of an internal buffer holding the bytes read. Do not free the buffer, copy it to keep it around.
/// @return false on NULL value, true if result was set to a value.
bool obx_fbr_read_bytes(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, OBX_bytes* _Nonnull outBytes);

#if __cplusplus
}
#endif


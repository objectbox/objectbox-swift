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

#include "obx_fbb.h"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdocumentation"
#include "flatbuffers/flatbuffers.h"
#pragma GCC diagnostic pop

#pragma mark Constants

const flatbuffers::uoffset_t COLLECTING_NOT_STARTED = -1;


#pragma mark Data Types

// Internal opaque struct used to keep around our state in a way that C callers (and therefore Swift)
// can deal with it.
struct OBX_fbb {
    bool isCollecting = false;
    flatbuffers::FlatBufferBuilder fbb;
    flatbuffers::uoffset_t collectedTableStart = COLLECTING_NOT_STARTED;
};

// flatbuffers::Table is a variable-length type with no virtual methods. The entire point of the struct below is to
// declare a C struct type that a flatbuffers::Table can be typecast to, and make the typecast back safer.
struct OBX_fbr: flatbuffers::Table {};

#pragma mark Macros

#if DEBUG
#define GUARD_IS_COLLECTING assert(self->isCollecting) // OBX_fbb methods should only be called during -put:error:.
#else
#define GUARD_IS_COLLECTING do {} while(0)
#endif
#define obx_is_started_fast(_self)          ((_self)->collectedTableStart != COLLECTING_NOT_STARTED)
#define obx_ensure_started_fast(_self)      do { if (!obx_is_started_fast(_self)) { (_self)->collectedTableStart = (_self)->fbb.StartTable(); } } while(0)

#pragma mark - Writing

extern "C" struct OBX_fbb* _Nonnull obx_fbb_create() {
    OBX_fbb* self = new OBX_fbb;
    
    self->fbb.ForceDefaults(true);

    return self;
}

extern "C" void obx_fbb_free(struct OBX_fbb* _Nonnull self) {
    delete self;
}

extern "C" bool obx_fbb_is_collecting(struct OBX_fbb* _Nonnull self) {
    return self->isCollecting;
}

extern "C" void obx_fbb_set_collecting(struct OBX_fbb* _Nonnull self, bool state) {
    self->isCollecting = state;
}

extern "C" void obx_fbb_finish(struct OBX_fbb* _Nonnull self, OBX_bytes *outBytes) {
    auto root = flatbuffers::Offset<flatbuffers::Table>(self->fbb.EndTable(self->collectedTableStart));
    self->fbb.Finish(root);
    outBytes->data = self->fbb.GetBufferPointer();
    outBytes->size = self->fbb.GetSize();
}


extern "C" bool obx_fbb_did_start(struct OBX_fbb* _Nonnull self) {
    return obx_is_started_fast(self);
}

extern "C" void obx_fbb_ensure_started(struct OBX_fbb* _Nonnull self) {
    obx_ensure_started_fast(self);
}

extern "C" void obx_fbb_clear(struct OBX_fbb* _Nonnull self) {
    self->collectedTableStart = COLLECTING_NOT_STARTED;
    self->fbb.Clear();
}

extern "C" void obx_fbb_collect_bool(struct OBX_fbb* _Nonnull self, bool value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<bool>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_int8(struct OBX_fbb* _Nonnull self, int8_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<int8_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_int16(struct OBX_fbb* _Nonnull self, int16_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<int16_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_int32(struct OBX_fbb* _Nonnull self, int32_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<int32_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_int64(struct OBX_fbb* _Nonnull self, int64_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<int64_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_uint8(struct OBX_fbb* _Nonnull self, uint8_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<uint8_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_uint16(struct OBX_fbb* _Nonnull self, uint16_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<uint16_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_uint32(struct OBX_fbb* _Nonnull self, uint32_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<uint32_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_uint64(struct OBX_fbb* _Nonnull self, uint64_t value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<uint64_t>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_float(struct OBX_fbb* _Nonnull self, float value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<float>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_double(struct OBX_fbb* _Nonnull self, double value, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    self->fbb.AddElement<double>(propertyOffset, value, 0);
}

extern "C" void obx_fbb_collect_data_offset(struct OBX_fbb* _Nonnull self, OBXDataOffset dataOffset, uint16_t propertyOffset) {
    GUARD_IS_COLLECTING;
    obx_ensure_started_fast(self);
    
    if (dataOffset == 0) { return; }

    flatbuffers::Offset<void> offset = (flatbuffers::Offset<void>)dataOffset;
    self->fbb.AddOffset(propertyOffset, offset);
}

extern "C" OBXDataOffset obx_fbb_prepare_string(struct OBX_fbb* _Nonnull self, const char* _Nonnull string) {
    GUARD_IS_COLLECTING;
    assert(!obx_is_started_fast(self)); // Strings must be collected before scalars.
    
    __block OBXDataOffset result = 0;
    try {
        flatbuffers::Offset<flatbuffers::String> stringOffset = self->fbb.CreateString(string, strlen(string));
        result = stringOffset.o;
    } catch(std::bad_alloc& err) {
        fprintf(stderr, "Unexpected bad_alloc error collecting string.");
        result = 0;
    }
    return result;
}

extern "C" OBXDataOffset obx_fbb_prepare_bytes(struct OBX_fbb* _Nonnull self, const void* _Nonnull bytes, size_t size) {
    GUARD_IS_COLLECTING;
    assert(!obx_is_started_fast(self)); // Byte vectors must be collected before scalars.
    
    OBXDataOffset result = 0;
    try {
        flatbuffers::Offset<flatbuffers::Vector<uint8_t>> vectorOffset = self->fbb.CreateVector((uint8_t *)bytes, size);
        result = vectorOffset.o;
    } catch(std::bad_alloc& err) {
        fprintf(stderr, "Unexpected bad_alloc error collecting byte vector.");
        result = 0;
    }
    return result;
}

#pragma mark - Reading

extern "C" const struct OBX_fbr* obx_fbr_get_root(const void* _Nonnull bytes) {
    return reinterpret_cast<const struct OBX_fbr*>(flatbuffers::GetRoot<flatbuffers::Table>(bytes));
}

extern "C" bool obx_fbr_read_bool(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, bool* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<bool>(value);
    return true;
}

extern "C" bool obx_fbr_read_int8(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int8_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<int8_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_int16(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int16_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<int16_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_int32(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int32_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<int32_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_int64(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, int64_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<int64_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_uint8(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint8_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<uint8_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_uint16(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint16_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<uint16_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_uint32(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint32_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<uint32_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_uint64(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, uint64_t* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<uint64_t>(value);
    return true;
}

extern "C" bool obx_fbr_read_float(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, float* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<float>(value);
    return true;
}

extern "C" bool obx_fbr_read_double(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, double* result) {
    const unsigned char* value = self->GetAddressOf(propertyOffset);
    if (!value) {
        return false;
    }
    *result = flatbuffers::ReadScalar<double>(value);
    return true;
}

extern "C" const char * _Nullable obx_fbr_read_string(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset) {
    const flatbuffers::String *string = self->GetPointer<const flatbuffers::String *>(propertyOffset);
    if (!string) {
        return nullptr;
    }
    return string->c_str();
}

extern "C" bool obx_fbr_read_bytes(const struct OBX_fbr* _Nonnull self, uint16_t propertyOffset, OBX_bytes* outBytes) {
    const flatbuffers::Vector<uint8_t> *vector = self->GetPointer<const flatbuffers::Vector<uint8_t> *>(propertyOffset);
    if (!vector) {
        return false;
    }
    
    outBytes->data = vector->data();
    outBytes->size = vector->size();
    
    return true;
}

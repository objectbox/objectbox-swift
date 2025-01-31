/*
 * Copyright 2024 ObjectBox Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// automatically generated by the FlatBuffers compiler, do not modify
// swiftlint:disable all
// swiftformat:disable all



///  The distance algorithm used by an HNSW index (vector search).
public enum HnswDistanceType: UInt16 {
  public typealias T = UInt16
  public static var byteSize: Int { return MemoryLayout<UInt16>.size }
  public var value: UInt16 { return self.rawValue }
  ///  Not a real type, just best practice (e.g. forward compatibility)
  case unknown = 0
  ///  The default; typically "Euclidean squared" internally.
  case euclidean = 1
  ///  Cosine similarity compares two vectors irrespective of their magnitude (compares the angle of two vectors).
  ///  Often used for document or semantic similarity.
  ///  Value range: 0.0 - 2.0 (0.0: same direction, 1.0: orthogonal, 2.0: opposite direction)
  case cosine = 2
  ///  For normalized vectors (vector length == 1.0), the dot product is equivalent to the cosine similarity.
  ///  Because of this, the dot product is often preferred as it performs better.
  ///  Value range (normalized vectors): 0.0 - 2.0 (0.0: same direction, 1.0: orthogonal, 2.0: opposite direction)
  case dotProduct = 3

  /// For geospatial coordinates aka latitude/longitude pairs.
  /// Note, that the vector dimension must be 2, with the latitude being the first element and longitude the second.
  /// Internally, this uses haversine distance.
  case geo = 6

  ///  A custom dot product similarity measure that does not require the vectors to be normalized.
  ///  Note: this is no replacement for cosine similarity (like DotProduct for normalized vectors is).
  ///  The non-linear conversion provides a high precision over the entire float range (for the raw dot product).
  ///  The higher the dot product, the lower the distance is (the nearer the vectors are).
  ///  The more negative the dot product, the higher the distance is (the farther the vectors are).
  ///  Value range: 0.0 - 2.0 (nonlinear; 0.0: nearest, 1.0: orthogonal, 2.0: farthest)
  case dotProductNonNormalized = 10

  public static var max: HnswDistanceType { return .dotProductNonNormalized }
  public static var min: HnswDistanceType { return .unknown }
}


///  Flags as a part of the HNSW configuration.
public enum HnswFlags: UInt32 {
  public typealias T = UInt32
  public static var byteSize: Int { return MemoryLayout<UInt32>.size }
  public var value: UInt32 { return self.rawValue }
  ///  Enables debug logs.
  case debugLogs = 1
  ///  Enables "high volume" debug logs, e.g. individual gets/puts.
  case debugLogsDetailed = 2
  ///  Padding for SIMD is enabled by default, which uses more memory but may be faster. This flag turns it off.
  case vectorCacheSimdPaddingOff = 4
  ///  If the speed of removing nodes becomes a concern in your use case, you can speed it up by setting this flag.
  ///  By default, repairing the graph after node removals creates more connections to improve the graph's quality.
  ///  The extra costs for this are relatively low (e.g. vs. regular indexing), and thus the default is recommended.
  case reparationLimitCandidates = 8

  public static var max: HnswFlags { return .reparationLimitCandidates }
  public static var min: HnswFlags { return .debugLogs }
}

extension Array where Element == HnswFlags {
    var rawValue: UInt32 {
        var combined: UInt32 = 0
        for value in self {
            combined |= value.rawValue
        }
        return combined
    }
}

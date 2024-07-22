//
// Copyright © 2024 ObjectBox Ltd. All rights reserved.
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

/// Wraps a matching object and a score when using ``Query/findWithScores(offset:limit:)``.
public class ObjectWithScore<T> {
    
    /// The object.
    public let object: T
    
    /// The query score for the ``object``.
    ///
    /// The query score indicates some quality measurement.
    /// E.g. for vector nearest neighbor searches, the score is the distance to the given vector.
    public let score: Double
    
    init(object: T, score: Double) {
        self.object = object
        self.score = score
    }
    
}

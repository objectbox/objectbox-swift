//  Copyright © 2018 ObjectBox. All rights reserved.

extension Array {
    func prepending(_ element: Element) -> [Element] {
        var result = [element]
        result.append(contentsOf: self)
        return result
    }
}

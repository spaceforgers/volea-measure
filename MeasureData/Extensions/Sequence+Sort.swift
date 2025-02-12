//
//  Sequence+Sort.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 12/2/25.
//

import Foundation

/// An extension on `Sequence` that adds a utility method for sorting elements based on a property.
///
/// This method leverages Swift’s key paths to extract a comparable property from each element.
/// The approach minimizes boilerplate, as the caller simply provides the key path for the desired property,
/// and the underlying closure for `sorted(by:)` is automatically generated. This design enforces compile-time
/// safety by ensuring that only properties conforming to `Comparable` can be used.
///
/// - Parameter keyPath: A key path that references the property of each element to be used for sorting.
/// - Returns: An array of the sequence’s elements, sorted in ascending order based on the property at the given key path.
public extension Sequence {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        // The closure compares the values extracted via the key path.
        // Using key paths here improves clarity by abstracting the detail of accessing the property.
        sorted { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}


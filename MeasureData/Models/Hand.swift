//
//  Hand.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation

/// Represents a hand side, either left or right, with an associated raw value.
///
/// This enum is designed to be both human-readable and compatible with SwiftUI’s
/// identification requirements by conforming to `Identifiable`. Its `CaseIterable` conformance
/// facilitates easy iteration (e.g., for UI selection lists), and the raw values provide a standardized
/// representation which could be useful for tasks like serialization or interfacing with external data sources.
public enum Hand: String, Identifiable, CaseIterable {
    /// Left hand represented with a raw value "left_hand".
    case left = "left_hand"
    
    /// Right hand represented with a raw value "right_hand".
    case right = "right_hand"
    
    /// Conformance to `Identifiable` by returning self as the unique identifier.
    /// Using `Self` here emphasizes that each case is unique in the domain of `Hand`.
    public var id: Self { self }
}

/// An extension that provides a human-friendly label for each `Hand` case.
///
/// The `label` computed property leverages Swift’s new switch expression syntax, allowing for a concise
/// and clear mapping from each enum case to its localized display string. This design makes the code
/// both readable and easy to extend or modify for localization purposes.
public extension Hand {
    var label: String {
        // The switch expression here directly returns a string based on the value of `self`,
        // making the mapping from enum case to display string succinct and clear.
        return switch self {
        case .left:
            "Left hand"
        case .right:
            "Right hand"
        }
    }
}


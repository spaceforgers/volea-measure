//
//  PadelMovementType.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation

/// Represents the various movement types in a padel game using string identifiers.
///
/// Conforming to `Identifiable` allows each case to be uniquely recognized in contexts such as SwiftUI lists,
/// while `CaseIterable` simplifies iterating over all possible values, for example, when building selection controls.
public enum PadelMovementType: String, Identifiable, CaseIterable {
    /// A forehand shot.
    case forehand = "forehand"
    /// A backhand shot.
    case backhand = "backhand"
    /// A volley shot.
    case volley = "volley"
    /// A serve.
    case serve = "serve"
    /// A smash shot.
    case smash = "smash"
    /// A lob shot.
    case lob = "lob"
    /// An undefined or unknown movement type.
    case unknown = "unknown"
    
    /// Provides a unique identifier for each movement type.
    ///
    /// Here, the enum case itself acts as its own unique ID, which is both semantically correct and practical for UI diffing.
    public var id: Self { self }
}

/// Provides a user-friendly label for each `PadelMovementType`.
///
/// The computed property `label` uses a switch expression to directly map each enum case to its corresponding
/// display string. This approach not only improves code clarity but also centralizes display logic,
/// making localization or future modifications straightforward.
public extension PadelMovementType {
    var label: String {
        return switch self {
        case .forehand:
            "Forehand"
        case .backhand:
            "Backhand"
        case .volley:
            "Volley"
        case .serve:
            "Serve"
        case .smash:
            "Smash"
        case .lob:
            "Lob"
        case .unknown:
            ""
        }
    }
}


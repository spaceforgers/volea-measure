//
//  WatchConnectivityStatus.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 27/10/24.
//

import SwiftUI

/// Represents the possible connectivity statuses between the iOS app and the Apple Watch.
///
/// Each case corresponds to a specific scenario encountered during watch connectivity.
/// This enum facilitates clean handling of connectivity states in the UI and business logic.
public enum WatchConnectivityStatus {
    /// Connectivity is not supported on the device.
    case notSupported
    /// The device is not paired with an Apple Watch.
    case notPaired
    /// The Apple Watch app is not installed on the paired watch.
    case NotInstalled
    /// The Apple Watch is paired but is currently not reachable (e.g., due to temporary disconnections).
    case NotReachable
    /// The connection to the Apple Watch is active and the watch is reachable.
    case reachable
}

/// Extension providing user-friendly representations of the connectivity status.
///
/// This extension maps each status to:
/// - A corresponding SF Symbol image name for iconography.
/// - Localized title and description strings for UI display.
/// - A color indicating the status severity (e.g., red for issues, green for success).
public extension WatchConnectivityStatus {
    
    /// Returns an SF Symbol system name representing the connectivity status.
    ///
    /// - Note: The chosen symbols visually communicate the state. A slashed watch icon indicates an issue,
    ///         while a checkmark represents a healthy connection.
    var systemName: String {
        return switch self {
        case .notSupported, .notPaired:
            "applewatch.slash"
        case .NotInstalled, .NotReachable:
            "exclamationmark.applewatch"
        case .reachable:
            "checkmark.applewatch"
        }
    }
    
    /// A localized title string that succinctly describes the connectivity status.
    ///
    /// The title is retrieved from the app's localization files, using keys specific to each status.
    /// This design centralizes user-facing text and simplifies localization.
    var title: String {
        return switch self {
        case .notSupported:
            String(localized: "WatchConnectivityStatus.notSupported.title", bundle: .module)
        case .notPaired:
            String(localized: "WatchConnectivityStatus.notPaired.title", bundle: .module)
        case .NotInstalled:
            String(localized: "WatchConnectivityStatus.NotInstalled.title", bundle: .module)
        case .NotReachable:
            String(localized: "WatchConnectivityStatus.NotReachable.title", bundle: .module)
        case .reachable:
            String(localized: "WatchConnectivityStatus.reachable.title", bundle: .module)
        }
    }
    
    /// A localized description string that provides additional details about the connectivity status.
    ///
    /// This description is intended for user interfaces where more context about the status is necessary.
    /// Localization keys ensure that the text is appropriately translated.
    var description: String {
        return switch self {
        case .notSupported:
            String(localized: "WatchConnectivityStatus.notSupported.description", bundle: .module)
        case .notPaired:
            String(localized: "WatchConnectivityStatus.notPaired.description", bundle: .module)
        case .NotInstalled:
            String(localized: "WatchConnectivityStatus.NotInstalled.description", bundle: .module)
        case .NotReachable:
            String(localized: "WatchConnectivityStatus.NotReachable.description", bundle: .module)
        case .reachable:
            String(localized: "WatchConnectivityStatus.reachable.description", bundle: .module)
        }
    }
    
    /// A color associated with the connectivity status, used for visual feedback in the UI.
    ///
    /// - Red indicates problematic states (e.g., unsupported or not paired).
    /// - Yellow warns of potential issues (e.g., temporary reachability problems).
    /// - Green signifies a successful, active connection.
    var color: Color {
        return switch self {
        case .notSupported, .notPaired, .NotInstalled:
            Color.red
        case .NotReachable:
            Color.yellow
        case .reachable:
            Color.green
        }
    }
}

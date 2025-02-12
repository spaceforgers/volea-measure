//
//  RecordingSession.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation
import SwiftData

/// A model representing a recording session that encapsulates a collection of movements along with a timestamp.
///
/// Conforming to `Identifiable` allows SwiftUI (or other frameworks) to uniquely reference each session.
/// The use of the `@Model` attribute suggests integration with a data persistence framework that recognizes
/// such annotations for managing object graphs.
///
/// The relationship to `RecordingMovement` is defined using the `@Relationship` property wrapper with a
/// cascade delete rule, meaning that all movements associated with this session will be deleted if the
/// session itself is removed. The `inverse` key path ensures referential integrity by linking each movement back
/// to its parent session.
@Model
public final class RecordingSession: Identifiable {
    /// A unique identifier for the recording session.
    public var id: UUID = UUID()
    
    /// The timestamp indicating when the session was created or recorded.
    public var timestamp: Date = Date()
    
    /// A collection of movements associated with this session.
    ///
    /// The `@Relationship` property wrapper defines a relationship with `RecordingMovement`.
    /// - `deleteRule: .cascade` ensures that when a `RecordingSession` is deleted, all associated movements are also removed.
    /// - `inverse: \RecordingMovement.session` establishes the bidirectional link, ensuring that each movement
    ///   knows its parent session.
    public var movements: [RecordingMovement]? = []
    
    /// Initializes a new instance of `RecordingSession`.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the session. Defaults to a new UUID.
    ///   - timestamp: The date and time when the session was recorded. Defaults to the current date.
    ///   - movements: An array of associated `RecordingMovement` objects. Defaults to an empty array.
    public init(id: UUID = UUID(),
                timestamp: Date = Date(),
                movements: [RecordingMovement] = []) {
        self.id = id
        self.timestamp = timestamp
        self.movements = movements
    }
}

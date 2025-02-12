//
//  CollectedMovement.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation
import SwiftData
import CoreMotion

/// A model representing a single movement recorded during a session.
///
/// This model captures the details of an individual movement, including the timestamp,
/// the type of movement, the hand used, and any associated motion data.
/// The model uses transient computed properties to bridge persisted raw data (strings)
/// with strongly-typed enums (`PadelMovementType` and `Hand`).
@Model
public final class RecordingMovement {
    /// An optional reference to the parent recording session.
    ///
    /// This link allows the movement to be associated with a specific session.
    public var session: RecordingSession?
    
    /// The timestamp when the movement was recorded.
    ///
    /// Defaults to the current date/time upon initialization.
    public var timestamp: Date = Date()
    
    /// Raw string data representing the movement type.
    ///
    /// This value is stored persistently and used to reconstruct a `PadelMovementType`
    /// via the transient computed property.
    public var movementTypeData: String = ""
    
    /// Raw string data representing the hand type used for the movement.
    ///
    /// This value is stored persistently and used to reconstruct a `Hand`
    /// via the transient computed property.
    public var handTypeData: String = ""
    
    /// A collection of associated motion data for this movement.
    ///
    /// The `@Relationship` property wrapper specifies a cascade delete rule:
    /// deleting a movement will also remove its associated motion data.
    /// The `inverse` key path establishes a bidirectional link with `RecordingMotionData`.
    @Relationship(deleteRule: .cascade, inverse: \RecordingMotionData.movement)
    public var motionData: [RecordingMotionData]? = []
    
    /// A computed property that maps the raw movement type data to a strongly-typed `PadelMovementType`.
    ///
    /// The getter attempts to initialize a `PadelMovementType` from `movementTypeData`.
    /// If the raw value doesn't match any known case, it defaults to `.unknown`.
    /// The setter updates the underlying raw data with the new value's raw representation.
    @Transient
    public var movementType: PadelMovementType {
        get { PadelMovementType(rawValue: movementTypeData) ?? .unknown }
        set { movementTypeData = newValue.rawValue }
    }
    
    /// A computed property that maps the raw hand type data to a strongly-typed `Hand`.
    ///
    /// The getter attempts to initialize a `Hand` from `handTypeData`.
    /// If the raw value doesn't match any known case, it defaults to `.right`.
    /// The setter updates the underlying raw data with the new value's raw representation.
    @Transient
    public var handType: Hand {
        get { Hand(rawValue: handTypeData) ?? .right }
        set { handTypeData = newValue.rawValue }
    }
    
    /// Initializes a new instance of `RecordingMovement`.
    ///
    /// - Parameters:
    ///   - session: An optional parent `RecordingSession` to which this movement belongs.
    ///   - timestamp: The time at which the movement was recorded. Defaults to the current date/time.
    ///   - movementType: The type of movement, expressed as a `PadelMovementType`.
    ///   - handType: The hand used during the movement, expressed as a `Hand`.
    ///   - motionData: An optional array of associated `RecordingMotionData`. Defaults to an empty array.
    public init(session: RecordingSession?,
                timestamp: Date = Date(),
                movementType: PadelMovementType,
                handType: Hand,
                motionData: [RecordingMotionData] = []) {
        self.session = session
        self.timestamp = timestamp
        // Using transient properties ensures that the underlying raw values are updated.
        self.movementType = movementType
        self.handType = handType
        self.motionData = motionData
    }
}


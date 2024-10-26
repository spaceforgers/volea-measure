//
//  CollectedSession.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation
import SwiftData

@Model
public final class CollectedSession: Identifiable {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var movementTypeData: String = ""
    public var handTypeData: String = ""
    
    @Relationship(deleteRule: .cascade, inverse: \CollectedMovement.session)
    public var movements: [CollectedMovement]? = []
    
    @Transient
    public var movementType: PadelMovementType {
        get { PadelMovementType(rawValue: movementTypeData) ?? .unknown }
        set { movementTypeData = newValue.rawValue }
    }
    
    @Transient
    public var handType: Hand {
        get { Hand(rawValue: handTypeData) ?? .right }
        set { handTypeData = newValue.rawValue }
    }
    
    public init(id: UUID = UUID(),
                timestamp: Date = Date(),
                movementType: PadelMovementType,
                handType: Hand,
                movements: [CollectedMovement] = []) {
        self.id = id
        self.timestamp = timestamp
        self.movementTypeData = movementType.rawValue
        self.handTypeData = handType.rawValue
        self.movements = movements
    }

}

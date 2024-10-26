//
//  CollectedMovement.swift
//
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation
import SwiftData
import CoreMotion

@Model
public final class CollectedMovement {
    public var session: CollectedSession?
    public var timestamp: Date = Date()
    public var accelerationX: Double = 0.0
    public var accelerationY: Double = 0.0
    public var accelerationZ: Double = 0.0
    public var rotationX: Double = 0.0
    public var rotationY: Double = 0.0
    public var rotationZ: Double = 0.0
    
    public init(session: CollectedSession?,
                timestamp: Date = Date(),
                accelerationX: Double,
                accelerationY: Double, 
                accelerationZ: Double,
                rotationX: Double,
                rotationY: Double,
                rotationZ: Double) {
        self.session = session
        self.timestamp = timestamp
        self.accelerationX = accelerationX
        self.accelerationY = accelerationY
        self.accelerationZ = accelerationZ
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.rotationZ = rotationZ
    }
}

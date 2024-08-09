//
//  MeasureCollector.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 3/8/24.
//

import Observation
import SwiftData
import HealthKit
import CoreMotion
import WatchConnectivity

@Observable
public final class MeasureCollector {
    public static let shared: MeasureCollector = MeasureCollector()
    
    @ObservationIgnored private let motionManager: CMMotionManager = CMMotionManager()
    @ObservationIgnored private var queue: OperationQueue = OperationQueue()
    
    public var isCollecting: Bool = false
    public var collectingSession: CollectedSession? = nil
    
    @ObservationIgnored private let minAccelerationMagnitude: Double = 1.0
    @ObservationIgnored private let minRotationMagnitude: Double = 1.0
    
    public init() {}
    
    public func startCollectingData(movementType: PadelMovementType, handType: Hand) {
        guard !isCollecting else { return }
        
        self.collectingSession = CollectedSession(movementType: movementType, handType: handType)
        self.queue = OperationQueue()
        self.isCollecting = true
        
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        self.motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (motion, error) in
            guard let self, let motion else { return }
            self.handleDeviceMotionUpdate(motion)
        }
    }
    
    public func stopCollectingData(context: ModelContext) {
        guard isCollecting else { return }
        
        self.isCollecting = false
        self.motionManager.stopDeviceMotionUpdates()
        
        guard let collectingSession else { return }
        context.insert(collectingSession)
    }
    
    private func handleDeviceMotionUpdate(_ motion: CMDeviceMotion) {
        guard let collectingSession else { return }
        
        let movement = CollectedMovement(session: collectingSession,
                                         accelerationX: motion.userAcceleration.x,
                                         accelerationY: motion.userAcceleration.y,
                                         accelerationZ: motion.userAcceleration.z,
                                         rotationX: motion.rotationRate.x,
                                         rotationY: motion.rotationRate.y,
                                         rotationZ: motion.rotationRate.z)
        
        collectingSession.movements.append(movement)
    }
}

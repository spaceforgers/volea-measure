//
//  MeasureCollector.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 3/8/24.
//

import Observation
import HealthKit
import CoreMotion
import WatchConnectivity

@Observable
public final class MeasureCollector {
    private let motionManager: CMMotionManager = CMMotionManager()
    private var queue: OperationQueue = OperationQueue()
    
    public var collectedData: [(motion: CMDeviceMotion, label: String)] = []
    
    public init() {}
    
    public func startCollectingData() {
        self.queue = OperationQueue()
        
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        self.motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (motion, error) in
            guard let self, let motion else { return }
            self.handleDeviceMotionUpdate(motion)
        }
    }
    
    public func stopCollectingData() {
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    func handleDeviceMotionUpdate(_ motion: CMDeviceMotion) {
        let acceleration = motion.userAcceleration
        let rotation = motion.rotationRate
        
        
    }
}

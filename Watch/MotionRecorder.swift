//
//  MotionRecorder.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 12/2/25.
//

import Foundation
import Observation
import CoreMotion
import SwiftData
import MeasureData

/// A class responsible for recording motion sensor data using Core Motion.
///
/// By marking the class as `@MainActor`, all mutable state is confined to the main actor.
/// This avoids data races in Swift 6’s strict concurrency mode.
@Observable
final class MotionRecorder {
    /// List of recorded motion data samples.
    var motionDataList: [RecordingMotionData] = []
    
    /// The timestamp of the first sensor reading in the current recording session.
    var recordingStartTimestamp: TimeInterval?
    
    /// The timestamp of the last received sensor update.
    var lastSensorTimestamp: TimeInterval?
    
    /// A sequential index incremented for each recorded sample.
    var sampleIndex: Int = 0

    /// The Core Motion manager that provides device motion updates.
    private let motionManager: CMMotionManager
    
    /// An operation queue dedicated to handling motion updates.
    /// This queue ensures that sensor updates are processed serially off the main thread.
    private let updateQueue: OperationQueue

    /// The interval between device motion updates (set to 60 Hz).
    private let motionInterval: TimeInterval = 1.0 / 60.0

    /// Initializes a new instance of `MotionRecorder`.
    ///
    /// This initializer configures the `CMMotionManager` with the desired update interval
    /// and sets up an operation queue for handling sensor updates.
    init() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = motionInterval

        updateQueue = OperationQueue()
        updateQueue.name = "com.spaceforgers.voleameasure.motionRecorderUpdateQueue"
        updateQueue.maxConcurrentOperationCount = 1
    }

    /// Starts recording motion sensor data.
    ///
    /// This method begins motion updates from the device's sensors. For each sensor update,
    /// it computes relative timestamps, updates the sample index, and then dispatches the creation
    /// of a `RecordingMotionData` instance onto the main actor.
    /// - Parameter movement: The `RecordingMovement` instance that will own the recorded data.
    func startRecording(for movement: RecordingMovement) {
        // Reset recording-related properties on the main actor.
        self.motionDataList.removeAll()
        self.recordingStartTimestamp = nil
        self.lastSensorTimestamp = nil
        self.sampleIndex = 0

        // Begin receiving device motion updates on the dedicated operation queue.
        motionManager.startDeviceMotionUpdates(to: updateQueue) { [weak self] data, error in
            // Ensure self and data exist.
            guard let self = self, let data = data else {
                if let error = error {
                    print("[MotionRecorder] Error: \(error.localizedDescription)")
                }
                return
            }

            // Update recording start timestamp if needed.
            if self.recordingStartTimestamp == nil {
                self.recordingStartTimestamp = data.timestamp
            }
            
            let sensorTimestamp = data.timestamp
            let relativeTimestamp = sensorTimestamp - (self.recordingStartTimestamp ?? sensorTimestamp)
            self.lastSensorTimestamp = sensorTimestamp
            let currentIndex = self.sampleIndex
            self.sampleIndex += 1

            let motionData = RecordingMotionData(
                movement: movement,
                timestamp: Date.now,
                sensorTimestamp: sensorTimestamp,
                relativeTimestamp: relativeTimestamp,
                index: currentIndex,
                userAccelerationX: data.userAcceleration.x,
                userAccelerationY: data.userAcceleration.y,
                userAccelerationZ: data.userAcceleration.z,
                rotationRateX: data.rotationRate.x,
                rotationRateY: data.rotationRate.y,
                rotationRateZ: data.rotationRate.z,
                attitudePitch: data.attitude.pitch,
                attitudeRoll: data.attitude.roll,
                attitudeYaw: data.attitude.yaw,
                attitudeQuaternionX: data.attitude.quaternion.x,
                attitudeQuaternionY: data.attitude.quaternion.y,
                attitudeQuaternionZ: data.attitude.quaternion.z,
                attitudeQuaternionW: data.attitude.quaternion.w,
                gravityX: data.gravity.x,
                gravityY: data.gravity.y,
                gravityZ: data.gravity.z,
                magneticFieldX: data.magneticField.field.x,
                magneticFieldY: data.magneticField.field.y,
                magneticFieldZ: data.magneticField.field.z
            )
            
            self.motionDataList.append(motionData)
        }
    }

    /// Stops recording motion sensor data.
    ///
    /// This method stops the device motion updates to conserve resources when recording is complete.
    func stopRecording() {
        motionManager.stopDeviceMotionUpdates()
    }
}

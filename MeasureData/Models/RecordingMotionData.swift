//
//  RecordingMotionData.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 27/10/24.
//

import Foundation
import SwiftData

/// A model representing a single sensor data sample captured during a movement recording.
///
/// This model encapsulates various sensor readings, such as accelerometer data (excluding gravity),
/// gyroscope data (rotation rates), device attitude in both Euler angles and quaternion forms,
/// gravity vectors, and magnetometer data. It is designed to be used in conjunction with
/// SwiftData (as suggested by the `@Model` attribute), and its structure reflects a comprehensive
/// snapshot of motion-related data at a given moment.
@Model
public final class RecordingMotionData {
    /// The parent movement instance that this sensor data sample is associated with.
    /// This optional relationship enables traversing from a movement to its constituent motion data.
    public var movement: RecordingMovement?
    
    // MARK: - Timestamps
    
    /// The absolute timestamp when this sensor data was recorded.
    public var timestamp: Date = Date()
    
    /// A sensor-provided timestamp that may be synchronized with the hardware clock.
    public var sensorTimestamp: TimeInterval = 0.0
    
    /// A relative timestamp, typically measured from the start of a recording session,
    /// to aid in reconstructing temporal sequences.
    public var relativeTimestamp: TimeInterval = 0.0
    
    /// A sequential index to denote the order of this data sample within a series.
    public var index: Int = 0
    
    // MARK: - User Acceleration (Excluding Gravity)
    
    /// Acceleration along the X-axis (in device-specific units), excluding gravitational effects.
    public var userAccelerationX: Double = 0.0
    /// Acceleration along the Y-axis (in device-specific units), excluding gravitational effects.
    public var userAccelerationY: Double = 0.0
    /// Acceleration along the Z-axis (in device-specific units), excluding gravitational effects.
    public var userAccelerationZ: Double = 0.0
    
    // MARK: - Gyroscope Data (Rotation Rate)
    
    /// The rotation rate around the X-axis in radians per second.
    public var rotationRateX: Double = 0.0
    /// The rotation rate around the Y-axis in radians per second.
    public var rotationRateY: Double = 0.0
    /// The rotation rate around the Z-axis in radians per second.
    public var rotationRateZ: Double = 0.0
    
    // MARK: - Attitude Data (Euler Angles)
    
    /// The pitch angle (rotation about the X-axis) in radians.
    public var attitudePitch: Double = 0.0
    /// The roll angle (rotation about the Y-axis) in radians.
    public var attitudeRoll: Double = 0.0
    /// The yaw angle (rotation about the Z-axis) in radians.
    public var attitudeYaw: Double = 0.0
    
    // MARK: - Attitude Data (Quaternion Representation)
    
    /// The X component of the attitude quaternion.
    public var attitudeQuaternionX: Double = 0.0
    /// The Y component of the attitude quaternion.
    public var attitudeQuaternionY: Double = 0.0
    /// The Z component of the attitude quaternion.
    public var attitudeQuaternionZ: Double = 0.0
    /// The W component of the attitude quaternion.
    ///
    /// A default value of 1.0 represents the identity quaternion (i.e., no rotation).
    public var attitudeQuaternionW: Double = 1.0
    
    // MARK: - Gravity Vector
    
    /// The gravity vector's X component as provided by Core Motion.
    public var gravityX: Double = 0.0
    /// The gravity vector's Y component as provided by Core Motion.
    public var gravityY: Double = 0.0
    /// The gravity vector's Z component as provided by Core Motion.
    public var gravityZ: Double = 0.0
    
    // MARK: - Magnetometer Data
    
    /// The calibrated magnetic field reading along the X-axis (typically in microteslas).
    public var magneticFieldX: Double = 0.0
    /// The calibrated magnetic field reading along the Y-axis (typically in microteslas).
    public var magneticFieldY: Double = 0.0
    /// The calibrated magnetic field reading along the Z-axis (typically in microteslas).
    public var magneticFieldZ: Double = 0.0
    
    /// Initializes a new instance of `RecordingMotionData` with the provided sensor readings.
    ///
    /// - Parameters:
    ///   - movement: The associated `RecordingMovement` instance, if available.
    ///   - timestamp: The absolute time at which this sample was recorded (default is current date/time).
    ///   - sensorTimestamp: The timestamp as provided by the sensor hardware.
    ///   - relativeTimestamp: The time offset relative to a reference (e.g., the start of recording).
    ///   - index: A sequential index to denote the order of this data sample.
    ///   - userAccelerationX: User acceleration along the X-axis (excluding gravity).
    ///   - userAccelerationY: User acceleration along the Y-axis (excluding gravity).
    ///   - userAccelerationZ: User acceleration along the Z-axis (excluding gravity).
    ///   - rotationRateX: Rotation rate around the X-axis (in radians per second).
    ///   - rotationRateY: Rotation rate around the Y-axis (in radians per second).
    ///   - rotationRateZ: Rotation rate around the Z-axis (in radians per second).
    ///   - attitudePitch: Pitch angle (Euler angle) of the device.
    ///   - attitudeRoll: Roll angle (Euler angle) of the device.
    ///   - attitudeYaw: Yaw angle (Euler angle) of the device.
    ///   - attitudeQuaternionX: The X component of the attitude quaternion.
    ///   - attitudeQuaternionY: The Y component of the attitude quaternion.
    ///   - attitudeQuaternionZ: The Z component of the attitude quaternion.
    ///   - attitudeQuaternionW: The W component of the attitude quaternion.
    ///   - gravityX: The X component of the gravity vector.
    ///   - gravityY: The Y component of the gravity vector.
    ///   - gravityZ: The Z component of the gravity vector.
    ///   - magneticFieldX: The calibrated magnetic field reading along the X-axis.
    ///   - magneticFieldY: The calibrated magnetic field reading along the Y-axis.
    ///   - magneticFieldZ: The calibrated magnetic field reading along the Z-axis.
    public init(movement: RecordingMovement?,
                timestamp: Date = Date(),
                sensorTimestamp: TimeInterval,
                relativeTimestamp: TimeInterval,
                index: Int,
                userAccelerationX: Double,
                userAccelerationY: Double,
                userAccelerationZ: Double,
                rotationRateX: Double,
                rotationRateY: Double,
                rotationRateZ: Double,
                attitudePitch: Double,
                attitudeRoll: Double,
                attitudeYaw: Double,
                attitudeQuaternionX: Double,
                attitudeQuaternionY: Double,
                attitudeQuaternionZ: Double,
                attitudeQuaternionW: Double,
                gravityX: Double,
                gravityY: Double,
                gravityZ: Double,
                magneticFieldX: Double,
                magneticFieldY: Double,
                magneticFieldZ: Double) {
        self.movement = movement
        self.timestamp = timestamp
        self.sensorTimestamp = sensorTimestamp
        self.relativeTimestamp = relativeTimestamp
        self.index = index
        self.userAccelerationX = userAccelerationX
        self.userAccelerationY = userAccelerationY
        self.userAccelerationZ = userAccelerationZ
        self.rotationRateX = rotationRateX
        self.rotationRateY = rotationRateY
        self.rotationRateZ = rotationRateZ
        self.attitudePitch = attitudePitch
        self.attitudeRoll = attitudeRoll
        self.attitudeYaw = attitudeYaw
        self.attitudeQuaternionX = attitudeQuaternionX
        self.attitudeQuaternionY = attitudeQuaternionY
        self.attitudeQuaternionZ = attitudeQuaternionZ
        self.attitudeQuaternionW = attitudeQuaternionW
        self.gravityX = gravityX
        self.gravityY = gravityY
        self.gravityZ = gravityZ
        self.magneticFieldX = magneticFieldX
        self.magneticFieldY = magneticFieldY
        self.magneticFieldZ = magneticFieldZ
    }
}

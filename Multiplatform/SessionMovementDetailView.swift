//
//  SessionMovementDetailView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 12/2/25.
//

import SwiftUI
import MeasureData

/// A SwiftUI view that displays the details of a recorded movement.
///
/// This view shows basic information (timestamp, hand used, and movement type), renders a 3D
/// visualization of the movement (if sensor data is available), and lists the raw motion data values
/// for in-depth analysis.
struct SessionMovementDetailView: View {
    /// The recorded movement whose details are displayed.
    var movement: RecordingMovement
    
    var body: some View {
        List {
            // MARK: Basic Movement Information
            Section {
                // Display the timestamp of the movement using a clock icon.
                Label(movement.timestamp.formatted(date: .omitted, time: .complete), systemImage: "clock")
                // Display the hand type with a hand icon, using a filled symbol variant.
                Label(movement.handType.label, systemImage: "hand.wave")
                    .symbolVariant(.fill)
                // Display the type of movement (e.g., forehand, backhand) with a tennis racket icon.
                Label(movement.movementType.label, systemImage: "tennis.racket")
            }
            
            // If motion data exists, show both a 3D visualization and a detailed list of raw data.
            if let motionData = movement.motionData?.sorted(by: \.index), !motionData.isEmpty {
                
                // MARK: 3D Visualization
                Section("3D Visualization") {
                    // Embed a SceneKit-based view that renders the motion data as a 3D trail and animated model.
                    SessionMovement3DView(motionData: motionData)
                        .frame(maxWidth: .infinity, minHeight: 420, alignment: .center)
                }
                
                // MARK: Raw Motion Data Details
                Section("Raw Data") {
                    // List each motion data sample for granular inspection.
                    ForEach(motionData) { data in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Index: \(data.index)")
                            
                            Text("Timestamp: \(data.timestamp.formatted())")
                            
                            Text("Sensor Timestamp: \(data.sensorTimestamp.formattedWithMilliseconds)")
                            
                            Text("Relative Timestamp: \(data.relativeTimestamp.formattedWithMilliseconds)")
                            
                            Text("User Acceleration: (\(data.userAccelerationX, specifier: "%.2f"), \(data.userAccelerationY, specifier: "%.2f"), \(data.userAccelerationZ, specifier: "%.2f"))")
                            
                            Text("Rotation Rate: (\(data.rotationRateX, specifier: "%.2f"), \(data.rotationRateY, specifier: "%.2f"), \(data.rotationRateZ, specifier: "%.2f"))")
                            
                            Text("Attitude (Pitch, Roll, Yaw): (\(data.attitudePitch, specifier: "%.2f"), \(data.attitudeRoll, specifier: "%.2f"), \(data.attitudeYaw, specifier: "%.2f"))")
                            
                            Text("Attitude Quaternion: (\(data.attitudeQuaternionX, specifier: "%.2f"), \(data.attitudeQuaternionY, specifier: "%.2f"), \(data.attitudeQuaternionZ, specifier: "%.2f"), \(data.attitudeQuaternionW, specifier: "%.2f"))")
                            
                            Text("Gravity: (\(data.gravityX, specifier: "%.2f"), \(data.gravityY, specifier: "%.2f"), \(data.gravityZ, specifier: "%.2f"))")
                            
                            Text("Magnetic Field: (\(data.magneticFieldX, specifier: "%.2f"), \(data.magneticFieldY, specifier: "%.2f"), \(data.magneticFieldZ, specifier: "%.2f"))")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        // The navigation title uses an abbreviated date and shortened time to keep it concise.
        .navigationTitle(movement.timestamp.formatted(date: .abbreviated, time: .shortened))
    }
}

//
//  SessionManager.swift
//  Volea Measure (Watch)
//
//  Created by Javier Galera Robles on 12/2/25.
//

import Foundation
import Observation
import SwiftData
import WatchKit
import MeasureData

/// Manages recording sessions and movements on the watch.
///
/// The `SessionManager` class is responsible for starting and stopping recording sessions as well as
/// individual movement recordings. It integrates with a `MotionRecorder` to collect sensor data and uses
/// a shared `ModelContext` to persist completed sessions. The class is marked as `@Observable`, allowing
/// SwiftUI views to react to changes in its properties.
@Observable
final class SessionManager {
    /// The currently active recording session.
    var currentSession: RecordingSession?
    
    /// The currently active movement within the session.
    var currentMovement: RecordingMovement?
    
    /// Indicates whether a recording session is currently in progress.
    var isRecordingSession: Bool = false
    
    /// Indicates whether a movement recording is currently in progress.
    var isRecordingMovement: Bool = false
    
    /// The motion recorder used to capture sensor data during a movement.
    let motionRecorder: MotionRecorder
    
    /// The model context used to persist recording sessions.
    let modelContext: ModelContext
    
    /// Initializes a new `SessionManager` with the provided model context.
    ///
    /// - Parameter modelContext: The shared persistence context for saving sessions.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.motionRecorder = MotionRecorder()
    }
    
    // MARK: - Session Management
    
    /// Starts a new recording session.
    ///
    /// This method creates a new `RecordingSession` and sets the appropriate flags to indicate that a session is active.
    func startSession() {
        currentSession = RecordingSession()
        isRecordingSession = true
    }
    
    // MARK: - Movement Recording
    
    /// Begins a new movement recording and starts collecting motion data.
    ///
    /// - Parameters:
    ///   - movementType: The type of movement being recorded (e.g., forehand, backhand).
    ///   - handType: The hand used to perform the movement (e.g., left or right).
    ///
    /// If there is an active session, this method creates a new `RecordingMovement` associated with that session,
    /// starts the motion recorder to collect sensor data, and triggers haptic feedback indicating the start of a movement.
    func startMovement(movementType: PadelMovementType, handType: Hand) {
        // Ensure that there is an active session.
        guard let session = currentSession else { return }
        
        // Create a new movement associated with the current session.
        let movement = RecordingMovement(session: session, movementType: movementType, handType: handType)
        currentMovement = movement
        
        // Begin collecting motion data for this movement.
        motionRecorder.startRecording(for: movement)
        
        // Update state to reflect that a movement is in progress.
        isRecordingMovement = true
        
        // Provide haptic feedback to indicate that movement recording has started.
        WKInterfaceDevice.current().play(.start)
    }
    
    /// Stops the current movement recording and integrates collected motion data.
    ///
    /// This method stops motion data updates, appends the collected sensor data to the current movement,
    /// adds the movement to the current session, and then resets the movement state. Haptic feedback is provided
    /// to signal the end of movement recording.
    func stopMovement() {
        // Ensure there is an active movement.
        guard let movement = currentMovement else { return }
        
        // Stop sensor updates.
        motionRecorder.stopRecording()
        
        // Append collected motion data to the movement.
        if movement.motionData == nil {
            movement.motionData = motionRecorder.motionDataList
        } else {
            movement.motionData!.append(contentsOf: motionRecorder.motionDataList)
        }
        
        // Add the movement to the current session's movements.
        if currentSession?.movements == nil {
            currentSession?.movements = [movement]
        } else {
            currentSession?.movements!.append(movement)
        }
        
        // Reset the current movement and clear temporary motion data.
        currentMovement = nil
        motionRecorder.motionDataList.removeAll()
        
        // Update state to indicate that movement recording has stopped.
        isRecordingMovement = false
        
        // Provide haptic feedback to indicate that movement recording has stopped.
        WKInterfaceDevice.current().play(.stop)
    }
    
    // MARK: - Finalizing Session
    
    /// Ends the current session and saves it using the shared model context.
    ///
    /// This method persists the recorded session (including its movements and associated motion data)
    /// to the model container. After saving, it resets the session state.
    func endSession() {
        guard let session = currentSession else { return }
        do {
            // Insert the session into the model context and save changes.
            modelContext.insert(session)
            try modelContext.save()
            
            // Reset session state.
            currentSession = nil
            isRecordingSession = false
        } catch {
            print("Error saving session: \(error)")
        }
    }
}

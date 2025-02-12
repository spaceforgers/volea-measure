//
//  WorkoutManager.swift
//  Volea Measure (Watch)
//
//  Created by Javier Galera Robles on 11/2/25.
//

import Foundation
import HealthKit

/// Manages HealthKit workout sessions on the watch.
///
/// By starting a workout session, the app can signal that the user is active. This helps
/// keep the app in the foreground and prevents the screen from locking. This class is responsible
/// for configuring, starting, and ending a workout session using HealthKit, and it logs changes in session state.
final class WorkoutManager: NSObject, HKWorkoutSessionDelegate {
    /// The HealthKit store used for managing workout sessions.
    private let healthStore = HKHealthStore()
    
    /// The current workout session, if one is active.
    private var workoutSession: HKWorkoutSession?
    
    /// Starts a new workout session.
    ///
    /// By creating and starting a workout session, the system treats the user as active.
    /// This is particularly useful on watchOS to prevent the screen from dimming or locking.
    /// The configuration used here is generic, assuming an indoor activity.
    func startWorkout() {
        // Create a workout configuration with generic settings.
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other          // Generic activity type.
        configuration.locationType = .indoor           // Assumes an indoor workout.
        
        do {
            // Initialize the workout session with the HealthKit store and the specified configuration.
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            // Set the delegate to receive state change updates.
            workoutSession?.delegate = self
            // Start the workout session at the current date/time.
            workoutSession?.startActivity(with: Date())
            print("[WorkoutManager] Workout session started.")
        } catch {
            // Log an error if the workout session could not be started.
            print("[WorkoutManager] Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    /// Ends the current workout session.
    ///
    /// This method stops the active workout session and sets the internal state to nil.
    /// Ending the workout session allows the system to update its activity state accordingly.
    func endWorkout() {
        // End the workout session if one exists.
        workoutSession?.end()
        // Clear the reference to the workout session.
        workoutSession = nil
        print("Workout session ended.")
    }
    
    // MARK: - HKWorkoutSessionDelegate Methods
    
    /// Called when the workout session changes state.
    ///
    /// This delegate method logs the state transition from the previous state to the new state,
    /// which can be useful for debugging and tracking workout session lifecycles.
    ///
    /// - Parameters:
    ///   - workoutSession: The workout session instance.
    ///   - toState: The new state of the workout session.
    ///   - fromState: The previous state of the workout session.
    ///   - date: The timestamp when the state change occurred.
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) {
        print("[WorkoutManager] Workout session changed from \(fromState) to \(toState).")
    }
    
    /// Called when the workout session fails with an error.
    ///
    /// If the workout session encounters an error, this delegate method logs the error's description.
    ///
    /// - Parameters:
    ///   - workoutSession: The workout session instance that failed.
    ///   - error: The error that caused the failure.
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("[WorkoutManager] Workout session error: \(error.localizedDescription)")
    }
}

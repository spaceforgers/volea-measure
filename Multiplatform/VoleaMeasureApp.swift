//
//  VoleaMeasureApp.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import WatchConnectivity
import MeasureData

/// The main application entry point for Volea Measure.
///
/// This struct sets up the SwiftUI scene, configures the data persistence container for the relevant models,
/// and provides a custom watch connectivity session delegate as an environment value.
@main
struct VoleaMeasureApp: App {
    // Using a State variable to instantiate and manage the lifecycle of the PhoneSessionDelegate.
    // This delegate is responsible for monitoring and handling watch connectivity events.
    @State var sessionDelegate: PhoneSessionDelegate = .init()
    
    var body: some Scene {
        WindowGroup {
            // The primary content view of the app.
            ContentView()
                // Inject the session delegate into the environment so that child views can react to connectivity status.
                .environment(sessionDelegate)
        }
        // Configure the SwiftData model container for our persistence models.
        // This container is responsible for managing RecordingSession, RecordingMovement, and RecordingMotionData entities.
        .modelContainer(for: [RecordingSession.self, RecordingMovement.self, RecordingMotionData.self]) { result in
            debugPrint(result)
        }
    }
}

/// A session delegate responsible for managing watch connectivity.
///
/// Conforming to `WCSessionDelegate`, this class monitors connectivity status changes with the paired Apple Watch
/// and sends commands to the watch as needed. It uses the `@Observable` attribute to allow SwiftUI views to react
/// to state changes (such as connectivity updates) automatically.
@Observable
final class PhoneSessionDelegate: NSObject, WCSessionDelegate {
    /// The current connectivity status, used to inform the UI.
    var status: WatchConnectivityStatus = .notSupported
    
    /// The underlying watch connectivity session.
    private var session: WCSession?
    
    /// Initializes a new session delegate.
    ///
    /// If watch connectivity is supported on the current device, this initializer activates the default session
    /// and sets this instance as its delegate. Otherwise, the status is set to `.notSupported`.
    override init() {
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            updateWatchConnectivityStatus()
        } else {
            status = .notSupported
        }
    }
    
    /// Updates the connectivity status based on the current WCSession properties.
    ///
    /// The status is updated within a `withAnimation` block to ensure smooth UI transitions. The method checks
    /// whether the session is paired, if the watch app is installed, and if the watch is reachable.
    private func updateWatchConnectivityStatus() {
        withAnimation {
            guard let session else {
                status = .notSupported
                return
            }
            
            if !session.isPaired {
                status = .notSupported
            } else if !session.isWatchAppInstalled {
                status = .NotInstalled
            } else if !session.isReachable {
                status = .NotReachable
            } else {
                status = .reachable
            }
        }
        
        print("[PHONE SESSION DELEGATE] Watch Connectivity Status: \(status)")
    }
    
    // MARK: - WCSessionDelegate Methods
    
    /// Called when the session becomes inactive.
    func sessionDidBecomeInactive(_ session: WCSession) {
        updateWatchConnectivityStatus()
        // Reactivate the session to ensure continued connectivity.
        session.activate()
    }
    
    /// Called when the session is deactivated.
    func sessionDidDeactivate(_ session: WCSession) {
        updateWatchConnectivityStatus()
    }
    
    /// Called when the session's activation completes.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        updateWatchConnectivityStatus()
    }
    
    /// Called when the session's reachability changes.
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateWatchConnectivityStatus()
    }
    
    // MARK: - Command Methods
    
    /// Sends a command to start a new session on the watch.
    func startSession() {
        let message: [String: Any] = ["command": "startSession"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending startSession command: \(error.localizedDescription)")
        }
    }
    
    /// Sends a command to start recording a movement with the specified type and hand.
    ///
    /// - Parameters:
    ///   - movementType: The type of padel movement to record.
    ///   - handType: The hand (left or right) used for the movement.
    func startMovementRecording(movementType: PadelMovementType, handType: Hand) {
        let message: [String: Any] = [
            "command": "startMovementRecording",
            "movementType": movementType.rawValue,
            "handType": handType.rawValue
        ]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending startMovementRecording command: \(error.localizedDescription)")
        }
    }
    
    /// Sends a command to stop the current movement recording.
    func stopMovementRecording() {
        let message: [String: Any] = ["command": "stopMovementRecording"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending stopMovementRecording command: \(error.localizedDescription)")
        }
    }
    
    /// Sends a command to end the current session on the watch.
    func endSession() {
        let message: [String: Any] = ["command": "endSession"]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending endSession command: \(error.localizedDescription)")
        }
    }
}

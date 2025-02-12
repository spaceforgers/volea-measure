//
//  WatchApp.swift
//  Volea Measure (Watch)
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import Observation
import CoreMotion
import WatchConnectivity
import MeasureData

/// The main entry point for the watch version of the Volea Measure app.
///
/// This struct sets up the primary SwiftUI scene, configures the persistence container
/// for the recording data models, and injects a custom watch session delegate into the environment.
@main
struct MyApp: App {
    /// A state property holding the watch session delegate.
    @State private var sessionDelegate: WatchSessionDelegate = .init()
    
    var body: some Scene {
        WindowGroup {
            // The root content view of the watch app.
            ContentView()
                // Inject the session delegate so that child views can access session and connectivity state.
                .environment(sessionDelegate)
        }
        // Set up the model container for SwiftData with the necessary models.
        .modelContainer(for: [RecordingSession.self, RecordingMovement.self, RecordingMotionData.self]) { result in
            debugPrint(result)
        }
    }
}

/// A delegate responsible for managing watch connectivity and session state on the watch.
///
/// The `WatchSessionDelegate` conforms to `WCSessionDelegate` to handle incoming messages
/// from the paired iPhone. It creates and manages a `SessionManager` that encapsulates session and
/// movement recording logic. The delegate initializes the persistence container for recording models,
/// ensuring that the watch app can persist session data.
@Observable
final class WatchSessionDelegate: NSObject, WCSessionDelegate {
    /// The session manager that handles recording sessions and movements.
    var sessionManager: SessionManager
    
    /// Initializes a new instance of `WatchSessionDelegate`.
    ///
    /// This initializer sets up a persistence container for the recording models, creates a corresponding
    /// model context, and instantiates the `SessionManager`. It also configures and activates the watch connectivity session.
    override init() {
        // Create the persistence container for the recording models.
        let container = try! ModelContainer(for: RecordingSession.self, RecordingMovement.self, RecordingMotionData.self)
        let context = ModelContext(container)
        // Initialize the session manager with the model context.
        self.sessionManager = SessionManager(modelContext: context)
        
        super.init()
        // Activate the WCSession if supported.
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    /// Called when the watch connectivity session has completed its activation.
    ///
    /// - Parameters:
    ///   - session: The WCSession instance.
    ///   - activationState: The state of the session after activation.
    ///   - error: An optional error if activation failed.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Activation complete – further handling can be implemented if needed.
    }
    
    /// Called when a message is received from the paired iPhone.
    ///
    /// The method extracts the command from the message dictionary and uses a Task block
    /// to forward the command to the session manager. Commands include starting/ending sessions
    /// and starting/stopping movement recordings.
    ///
    /// - Parameters:
    ///   - session: The current WCSession.
    ///   - message: The message dictionary received from the iPhone.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        Task {
            // Extract the command from the message.
            guard let command = message["command"] as? String else { return }
            switch command {
                case "startSession":
                    sessionManager.startSession()
                    
                case "endSession":
                    sessionManager.endSession()
                    
                case "startMovementRecording":
                    // Parse the movement type and hand type from the message.
                    if let movementTypeRaw = message["movementType"] as? String,
                       let handTypeRaw = message["handType"] as? String,
                       let movementType = PadelMovementType(rawValue: movementTypeRaw),
                       let handType = Hand(rawValue: handTypeRaw) {
                        sessionManager.startMovement(movementType: movementType, handType: handType)
                    }
                    
                case "stopMovementRecording":
                    sessionManager.stopMovement()
                    
                default:
                    break
            }
        }
    }
}

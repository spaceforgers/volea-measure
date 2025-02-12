//
//  ContentView.swift
//  Volea Measure (Watch)
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import CoreMotion
import WatchConnectivity
import MeasureData

/// The main view for the watch app that displays recording status and instructions.
///
/// This view dynamically updates its content based on the state of the recording session,
/// which is managed by the watch session delegate. It shows a custom animated image when
/// a session is active, displays status messages for movement recording, and falls back
/// to instructing the user to use the iPhone app when no session is in progress.
struct ContentView: View {
    // Inject the watch session delegate from the environment.
    // The delegate provides access to session-related state (e.g. whether a session or movement is active).
    @Environment(WatchSessionDelegate.self) var sessionDelegate
    
    var body: some View {
        VStack {
            // If a recording session is active, display session-specific UI.
            if sessionDelegate.sessionManager.isRecordingSession {
                // Custom image indicating recording activity.
                // The pulse effect and red accent convey urgency and recording status.
                Image("custom.figure.tennis.badge.record")
                    .symbolEffect(.pulse)
                    .font(.largeTitle)
                    .foregroundStyle(.red, .primary)
                    .padding()
                
                // Display a dynamic message depending on whether a movement is being recorded.
                Text(sessionDelegate.sessionManager.isRecordingMovement ? "Recording movement..." : "Get ready!")
                    .font(.headline)
                
                Spacer()
                    
                // If a session is active but a movement is not currently being recorded,
                // instruct the user that the iPhone app will trigger the recording.
                if !sessionDelegate.sessionManager.isRecordingMovement {
                    Text("Waiting for iPhone to start recording a movement.")
                }
                
                Spacer()
                
                // Show the count of recorded movements (if available).
                Text("\(sessionDelegate.sessionManager.currentSession?.movements?.count ?? 0) movements recorded")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
            } else {
                // If no recording session is active, guide the user to use the iPhone app.
                Image(systemName: "iphone")
                    .font(.largeTitle)
                    .padding()
                Text("Use the iPhone app")
                    .font(.headline)
                Text("To start recording your movements and see the results.")
                    .font(.subheadline)
            }
        }
        // Center align all multiline text for better readability.
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ContentView()
}

//
//  RecordingSessionView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 27/10/24.
//

import SwiftUI
import WatchConnectivity
import MeasureData

/// A SwiftUI view for managing a recording session.
///
/// This view allows users to start and finish a recording session and to record individual movements.
/// It leverages a session delegate (likely conforming to a custom protocol) for communication with a paired watch,
/// and conditionally enables UI elements based on the connectivity status and current recording state.
struct RecordingSessionView: View {
    // MARK: - Environment and State
    
    /// Used to dismiss the view when the session is finished.
    @Environment(\.dismiss) private var dismiss
    
    /// A delegate that handles session-related events and communicates with the watch.
    @Environment(PhoneSessionDelegate.self) private var sessionDelegate
    
    /// Indicates whether a recording session is currently active.
    @State private var isRecordingSession: Bool = false
    
    /// Indicates whether a movement is currently being recorded within an active session.
    @State private var isRecordingMovement: Bool = false
    
    /// The selected hand type (e.g., left or right) used for movement recording.
    @State private var selectedHandType: Hand = .left
    
    /// The selected movement type (e.g., backhand, forehand) for the recorded movement.
    @State private var selectedMovementType: PadelMovementType = .backhand
    
    // MARK: - Layout Constants
    
    /// Constants used for styling the connectivity status alert.
    private let statusAlertImageSize: CGFloat = 32.0
    private let statusAlertCornerRadius: CGFloat = 16.0
    private let statusAlertTitleLineSpacing: CGFloat = 2.0
    private let statusAlertDescriptionTopPadding: CGFloat = 4.0
    
    /// Maximum height for the bottom control buttons.
    private let bottomButtonsMaxHeight: CGFloat = 48.0
    
    // MARK: - View Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recording Session")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // "Done" button for dismissing the view.
                    // Disabled while a session is active to prevent premature exit.
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .disabled(isRecordingSession)
                    }
                }
        }
    }
    
    // MARK: - Main Content View
    
    /// The main content of the view, which includes connectivity status, picker controls, and recording buttons.
    private var content: some View {
        VStack {
            Spacer()
            
            // Show connectivity status alert if the watch is not reachable.
            if sessionDelegate.status != .reachable {
                HStack {
                    // Status icon representing the connectivity state.
                    Image(systemName: sessionDelegate.status.systemName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.thickMaterial)
                        .frame(width: statusAlertImageSize, height: statusAlertImageSize)
                    
                    // Localized title and description for the connectivity status.
                    VStack(alignment: .leading) {
                        Text(sessionDelegate.status.title)
                            .foregroundStyle(.thickMaterial)
                            .lineSpacing(statusAlertTitleLineSpacing)
                        
                        Text(sessionDelegate.status.description)
                            .font(.caption)
                            .foregroundStyle(.regularMaterial)
                            .padding(.top, statusAlertDescriptionTopPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(sessionDelegate.status.color)
                .clipShape(.rect(cornerRadius: statusAlertCornerRadius))
                // Combined transition for appearance/disappearance animations.
                .transition(.scale.combined(with: .blurReplace))
                .padding()
            }
            
            // Picker controls for selecting hand and movement types.
            HStack {
                Picker(selection: $selectedHandType) {
                    ForEach(Hand.allCases) { hand in
                        Text(hand.label)
                    }
                } label: {
                    Label(selectedHandType.label, systemImage: "hand.wave")
                        .frame(maxWidth: .infinity, maxHeight: bottomButtonsMaxHeight)
                }
                // Disable selection if the watch is not reachable or a movement recording is active.
                .disabled(sessionDelegate.status != .reachable || isRecordingMovement)
                .pickerStyle(.menu)
                .buttonStyle(.bordered)
                
                Picker(selection: $selectedMovementType) {
                    ForEach(PadelMovementType.allCases) { movement in
                        Text(movement.label)
                    }
                } label: {
                    Label(selectedMovementType.label, systemImage: "tennis.racket")
                        .frame(maxWidth: .infinity, maxHeight: bottomButtonsMaxHeight)
                }
                // Disable selection if the watch is not reachable or a movement recording is active.
                .disabled(sessionDelegate.status != .reachable || isRecordingMovement)
                .pickerStyle(.menu)
                .buttonStyle(.bordered)
            }
            .padding()
            
            // Control buttons for recording movements and managing the session.
            HStack {
                // If a session is active, display a button to start/stop a movement.
                if isRecordingSession {
                    Button(role: isRecordingMovement ? .destructive : nil) {
                        if isRecordingMovement {
                            // Stop the current movement recording.
                            isRecordingMovement = false
                            sessionDelegate.stopMovementRecording()
                        } else {
                            // Start a new movement recording with selected parameters.
                            isRecordingMovement = true
                            sessionDelegate.startMovementRecording(movementType: selectedMovementType, handType: selectedHandType)
                        }
                    } label: {
                        Label(isRecordingMovement ? "Stop Movement" : "Record Movement",
                              image: isRecordingMovement ? .customFigureTennisBadgePause : .customFigureTennisBadgePlay)
                            .frame(maxWidth: .infinity, maxHeight: bottomButtonsMaxHeight)
                    }
                    .buttonStyle(.bordered)
                    // The button is enabled only when the watch is reachable and a session is active.
                    .disabled(sessionDelegate.status != .reachable || !isRecordingSession)
                    // Provide haptic or other sensory feedback based on the recording state change.
                    .sensoryFeedback(trigger: isRecordingMovement) { _, newValue in
                        return switch newValue {
                        case true: .start
                        case false: .stop
                        }
                    }
                }
                
                // Button to start/finish the overall session.
                Button(role: isRecordingSession ? .destructive : nil) {
                    if isRecordingSession {
                        // Finishing an active session: stop recording and dismiss the view.
                        isRecordingSession = false
                        sessionDelegate.endSession()
                        dismiss()
                    } else {
                        // Start a new session.
                        isRecordingSession = true
                        sessionDelegate.startSession()
                    }
                } label: {
                    Label(isRecordingSession ? "Finish Session" : "Start Session",
                          systemImage: isRecordingSession ? "stop" : "play")
                        .symbolVariant(.fill)
                        .frame(maxWidth: .infinity, maxHeight: bottomButtonsMaxHeight)
                }
                .buttonStyle(.borderedProminent)
                // Disable the button if the watch is not reachable or a movement recording is active.
                .disabled(sessionDelegate.status != .reachable || isRecordingMovement)
                .sensoryFeedback(trigger: isRecordingSession) { _, newValue in
                    return switch newValue {
                    case true: .start
                    case false: .stop
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    RecordingSessionView()
}

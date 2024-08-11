//
//  RecordingView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 9/8/24.
//

import SwiftUI
import WatchConnectivity
import MeasureData

struct RecordingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var sessionStatus: SessionStatus = .unknown
    
    @State private var movementType: PadelMovementType = .backhand
    @State private var handType: Hand = .right
    
    @State private var sessionCheckTimer: Timer?
    @State private var isRecording: Bool = false
    
    private let statusAlertCornerRadius: CGFloat = 16.0
    private let statusAlertIconSize: CGFloat = 32.0
    private let startStopButtonMaxHeight: CGFloat = 32.0
    
    var body: some View {
        VStack {
            if sessionStatus != .active && sessionStatus != .unknown {
                statusAlert
            }
            
            Spacer()
            startStopButton
        }
        .onAppear {
            self.startSessionMonitoring()
        }
    }
    
    @ViewBuilder
    private var startStopButton: some View {
        Button(action: {
            withAnimation {
                isRecording ? sendStopCommand() : sendStartCommand()
            }
            
        }, label: {
            Label(isRecording ? "Stop" : "Start", systemImage: isRecording ? "stop" : "play")
                .symbolVariant(.fill)
                .frame(maxWidth: .infinity, maxHeight: startStopButtonMaxHeight)
        })
        .padding()
        .buttonStyle(.borderedProminent)
        .tint(isRecording ? Color.red : Color.green)
        .disabled(sessionStatus != .active)
    }
    
    @ViewBuilder
    private var statusAlert: some View {
        HStack {
            Image(systemName: "exclamationmark.applewatch")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.thickMaterial)
                .frame(width: statusAlertIconSize, height: statusAlertIconSize)
            
            VStack(alignment: .leading) {
                Text(sessionStatus.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.thickMaterial)
                Text(sessionStatus.description)
                    .font(.caption)
                    .foregroundStyle(.thickMaterial)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .clipShape(.rect(cornerRadius: statusAlertCornerRadius))
        .shadow(color: .primary.opacity(0.2), radius: statusAlertCornerRadius)
        .padding()
        .transition(.scale)
    }
    
    private func startSessionMonitoring() {
        self.sessionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkSessionStatus()
        }
    }
    
    private func checkSessionStatus() {
        guard sessionStatus != .active else {
            return
        }
        
        guard WCSession.isSupported() else {
            self.sessionStatus = .unknown
            return
        }
        
        let session = WCSession.default
        
        withAnimation {
            if !session.isPaired {
                self.sessionStatus = .isNotPaired
                
            } else if !session.isWatchAppInstalled {
                self.sessionStatus = .isNotInstalled
                
            } else if !session.isReachable {
                self.sessionStatus = .isNotReachable
                
            } else {
                self.sessionStatus = .active
            }
        }
    }
    
    private func sendStartCommand() {
        guard WCSession.default.isReachable  else { return }
        
        let message: [String: Any] = [
            "command": "START",
            "movementType": movementType.rawValue,
            "handType": handType.rawValue
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { _ in
            isRecording = true
        }) { error in
            print("[WCSession] Error sending START command: \(error.localizedDescription)")
        }
    }
    
    private func sendStopCommand() {
        guard WCSession.default.isReachable  else { return }
        
        let message: [String: Any] = [
            "command": "STOP",
            "context": modelContext
        ]
        
        WCSession.default.sendMessage(message, replyHandler: { _ in
            isRecording = false
        }) { error in
            print("[WCSession] Error sending STOP command: \(error.localizedDescription)")
        }
    }
}

fileprivate enum SessionStatus {
    case active
    case isNotPaired
    case isNotReachable
    case isNotInstalled
    case isNotEnabled
    case unknown
    
    var title: String {
        return switch self {
            case .isNotPaired:
                "Your iPhone has no Apple Watch paired."
            case .isNotReachable:
                "Your Apple Watch is not reachable."
            case .isNotInstalled:
                "Volea Measure is not installed on your Apple Watch."
            case .isNotEnabled:
                "Volea Measure is not running on your Apple Watch."
            case .active, .unknown:
                ""
        }
    }
    
    var description: String {
        return switch self {
            case .isNotPaired:
                "To be able to record data you need to pair an Apple Watch to your iPhone."
            case .isNotEnabled, .isNotReachable:
                "Open Volea Measure on your Apple Watch to begin recording data."
            case .isNotInstalled:
                "Install Volea Measure on your Apple Watch to begin recording data."
            case .active, .unknown:
                ""
        }
    }
}

#Preview {
    RecordingView()
}

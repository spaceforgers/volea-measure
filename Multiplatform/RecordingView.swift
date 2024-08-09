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
    
    var body: some View {
        VStack {
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
            isRecording ? sendStopCommand() : sendStartCommand()
        }, label: {
            Label(isRecording ? "Stop" : "Start", systemImage: isRecording ? "stop" : "play")
                .symbolVariant(.fill)
                .font(.title)
        })
        .buttonStyle(.borderedProminent)
        .disabled(sessionStatus != .active)
    }
    
    private func startSessionMonitoring() {
        self.sessionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkSessionStatus()
        }
    }
    
    private func checkSessionStatus() {
        guard WCSession.isSupported() else {
            self.sessionStatus = .unknown
            return
        }
        
        let session = WCSession.default
        
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
            case .active:
                ""
            case .isNotPaired:
                ""
            case .isNotReachable:
                ""
            case .isNotInstalled:
                ""
            case .isNotEnabled:
                ""
            case .unknown:
                ""
        }
    }
    
    var description: String {
        return switch self {
            case .active:
                ""
            case .isNotPaired:
                ""
            case .isNotReachable:
                ""
            case .isNotInstalled:
                ""
            case .isNotEnabled:
                ""
            case .unknown:
                ""
        }
    }
}

#Preview {
    RecordingView()
}

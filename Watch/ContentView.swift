//
//  ContentView.swift
//  Volea Measure Watch App
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import CoreMotion
import WatchConnectivity

import MeasureData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var motionManager: CMMotionManager = CMMotionManager()
    @State private var timer: Timer?
    @State private var elapsedTimeTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    
    @State private var selectedMove: PadelMovementType = .backhand
    @State private var selectedHand: Hand = .left
    @State private var isRecording: Bool = false
    
    @State private var motionDataList: [CollectedMovement] = []
    
    var body: some View {
        VStack {
            if isRecording {
                Text(formatTime(elapsedTime))
                    .font(.largeTitle)
                    .fontDesign(.monospaced)
                    .contentTransition(.numericText())
                
                Text("\(selectedMove.label) with \(selectedHand.label)")
                    .font(.caption)
                    .padding()
                
                Button("Stop Recoding") {
                    stopRecording()
                }
                .padding()
                
            } else {
                Picker("Select Move", selection: $selectedMove) {
                    ForEach(PadelMovementType.allCases) { move in
                        Text(move.label)
                            .tag(move)
                    }
                }
                
                Picker("Select Hand", selection: $selectedHand) {
                    ForEach(Hand.allCases) { hand in
                        Text(hand.label)
                            .tag(hand)
                    }
                }
                
                Button("Start Recoding") {
                    startRecording()
                }
                .padding()
            }
        }
        .onAppear {
            // Initialize WCSession
            if WCSession.isSupported() {
                WCSession.default.activate()
            }
        }
    }
    
    private func startRecording() {
        isRecording = true
        
        // Reset motion list and timer
        elapsedTime = 0
        motionDataList = []
        
        // Configure motion manager
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        
        // Start motion updates
        motionManager.startDeviceMotionUpdates()
        
        // Start the elapsed time timer
        elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
        
        // Start timer to collect data
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
            if let data = motionManager.deviceMotion {
                let movement = CollectedMovement(session: nil,
                                                 timestamp: .now,
                                                 accelerationX: data.userAcceleration.x,
                                                 accelerationY: data.userAcceleration.y,
                                                 accelerationZ: data.userAcceleration.z,
                                                 rotationX: data.rotationRate.x,
                                                 rotationY: data.rotationRate.y,
                                                 rotationZ: data.rotationRate.z)
                
                motionDataList.append(movement)
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        
        motionManager.stopDeviceMotionUpdates()
        timer?.invalidate()
        elapsedTimeTimer?.invalidate()
        elapsedTimeTimer = nil
        
        // Save session to SwiftData
        let session = CollectedSession(movementType: selectedMove, handType: selectedHand)
        modelContext.insert(session)
        
        for movement in motionDataList {
            movement.session = session
            modelContext.insert(movement)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving session: \(error)")
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}

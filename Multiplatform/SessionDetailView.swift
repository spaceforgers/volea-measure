//
//  SessionDetailView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 26/10/24.
//

import SwiftUI
import MeasureData

struct SessionDetailView: View {
    var session: CollectedSession
    
    var body: some View {
        List {
            Section {
                Label(session.timestamp.formatted(.dateTime), systemImage: "calendar")
                Label(session.handType.label, systemImage: "hand.wave.fill")
                Label(session.movementType.label, systemImage: "tennis.racket")
            }
            
            Section(content: {
                if let movements = session.movements?.sorted(by: { $0.timestamp > $1.timestamp }), !movements.isEmpty {
                    ForEach(movements) { movement in
                        VStack(alignment: .leading) {
                            Label(movement.timestamp.formatted(date: .omitted, time: .complete), systemImage: "clock")
                            Label("Acceleration X: \(movement.accelerationX)", systemImage: "move.3d")
                            Label("Acceleration Y: \(movement.accelerationY)", systemImage: "move.3d")
                            Label("Acceleration Z: \(movement.accelerationZ)", systemImage: "move.3d")
                            Label("Rotation X: \(movement.rotationX)", systemImage: "rotate.3d")
                            Label("Rotation Y: \(movement.rotationY)", systemImage: "rotate.3d")
                            Label("Rotation Z: \(movement.rotationZ)", systemImage: "rotate.3d")
                        }
                    }
                    
                } else {
                    ContentUnavailableView("No recorded data", systemImage: "figure.tennis")
                }
                
            }, header: {
                Text("Recorded Data")
            })
        }
        .navigationBarTitle("Session Details")
        
        .toolbar {
            
        }
    }
}

#Preview {
    SessionDetailView(session: CollectedSession(movementType: .backhand, handType: .left))
}

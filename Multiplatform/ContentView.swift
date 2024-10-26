//
//  ContentView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import MeasureData

struct ContentView: View {
    @Query(sort: \CollectedSession.timestamp, order: .reverse) private var sessions: [CollectedSession]
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Records")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        
                    }
                }
            
                .navigationDestination(for: CollectedSession.self, destination: SessionDetailView.init)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        List(sessions) { session in
            NavigationLink(value: session, label: {
                VStack(alignment: .leading) {
                    Text(session.timestamp.formatted(date: .numeric, time: .shortened))
                    Text("\(session.movementType.label) - \(session.handType.label) - \(session.movements?.count ?? 0) moves")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            })
        }
    }
}

#Preview {
    ContentView()
}

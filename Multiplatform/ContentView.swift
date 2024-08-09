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
    @Query private var sessions: [CollectedSession]
    
    @State private var selection = Set<CollectedSession>()
    @State private var isRecordingViewPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Volea Measure")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isRecordingViewPresented.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
            
                .sheet(isPresented: $isRecordingViewPresented, content: {
                    RecordingView()
                })
        }
    }
    
    @ViewBuilder
    private var content: some View {
        List(sessions, selection: $selection) { session in
            
        }
    }
}

#Preview {
    ContentView()
}

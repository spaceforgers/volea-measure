//
//  ContentView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Volea Measure")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Export") {
                            
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        List {
            
        }
    }
}

#Preview {
    ContentView()
}

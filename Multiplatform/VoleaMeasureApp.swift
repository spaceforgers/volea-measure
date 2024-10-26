//
//  VoleaMeasureApp.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import WatchConnectivity
import MeasureData

@main
struct VoleaMeasureApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [CollectedSession.self, CollectedMovement.self]) { result in
                    debugPrint(result)
                }
        }
    }
}

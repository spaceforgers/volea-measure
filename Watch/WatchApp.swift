//
//  WatchApp.swift
//  Volea Measure (Watch)
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import WatchConnectivity
import MeasureData

@main
struct WatchApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    @State var collector = MeasureCollector.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [CollectedSession.self, CollectedMovement.self]) { result in
                    debugPrint(result)
                }
            
                .environment(collector)
        }
    }
}

final class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let command = message["command"] as? String {
            switch command {
                case "START":
                    if let movementTypeRaw = message["movementType"] as? String,
                       let handTypeRaw = message["handType"] as? String,
                       let movementType = PadelMovementType(rawValue: movementTypeRaw),
                       let handType = Hand(rawValue: handTypeRaw) {
                        MeasureCollector.shared.startCollectingData(movementType: movementType, handType: handType)
                    }
                    
                case "STOP":
                    if let context = message["context"] as? ModelContext {
                        MeasureCollector.shared.stopCollectingData(context: context)
                    }
                    
                default:
                    break
            }
        }
    }
}

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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [CollectedSession.self, CollectedMovement.self]) { result in
                    debugPrint(result)
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, WCSessionDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        return true
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessage(message: message)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        handleMessage(message: applicationContext)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error {
            print("[WCSession] Error activating the session: \(error.localizedDescription)")
        } else {
            print("[WCSession] Session activated with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[WCSession] Session inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("[WCSession] Session inactive. Trying to activate again.")
        session.activate()
    }
    
    private func handleMessage(message: [String: Any]) {
        if let command = message["command"] as? String {
            switch command {
                case "START":
                    print("[WCSession] Sending START command to Apple Watch...")
                    break
                case "STOP":
                    print("[WCSession] Sending STOP command to Apple Watch...")
                    break
                default:
                    print("[WCSession] Command not recognized.")
                    break
            }
        }
        
        if let additionalData = message["additionalData"] as? String {
            print("[WCSession] Additional data received: \(additionalData)")
        }
    }
}

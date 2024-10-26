//
//  PadelMovementType.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation

public enum PadelMovementType: String, Identifiable, CaseIterable {
    case forehand = "forehand"
    case backhand = "backhand"
    case volley = "volley"
    case serve = "serve"
    case smash = "smash"
    case lob = "lob"
    case unknown = "unknown"
    
    public var id: Self { self }
}

public extension PadelMovementType {
    var label: String {
        return switch self {
            case .forehand:
                "Forehand"
            case .backhand:
                "Backhand"
            case .volley:
                "Volley"
            case .serve:
                "Serve"
            case .smash:
                "Smash"
            case .lob:
                "Lob"
            case .unknown:
                ""
        }
    }
}

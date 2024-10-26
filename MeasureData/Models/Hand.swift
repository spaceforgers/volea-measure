//
//  Hand.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 9/8/24.
//

import Foundation

public enum Hand: String, Identifiable, CaseIterable {
    case left = "left_hand"
    case right = "right_hand"
    
    public var id: Self { self }
}

public extension Hand {
    var label: String {
        return switch self {
            case .left:
                "Left hand"
            case .right:
                "Right hand"
        }
    }
}

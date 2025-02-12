//
//  TimeInterval+Format.swift
//  MeasureData
//
//  Created by Javier Galera Robles on 12/2/25.
//

import Foundation

/// An extension on `TimeInterval` that provides a formatted string representation
/// including hours, minutes, seconds, and milliseconds.
///
/// This computed property converts the time interval (in seconds) to a human-readable
/// string format `HH:MM:SS.MMM`. It multiplies the time interval by 1000 to work entirely in
/// milliseconds, applying a rounding operation to account for any fractional part. This approach
/// minimizes floating-point inaccuracies during the conversion process.
///
/// The design decision to use integer arithmetic after conversion ensures that the division and
/// modulo operations produce reliable results. The formatted output is padded with zeros to maintain
/// a consistent width, which is essential for readability in logs or user interfaces.
public extension TimeInterval {
    var formattedWithMilliseconds: String {
        // Convert the time interval to milliseconds, rounding to handle fractional values.
        let totalMilliseconds = Int((self * 1000).rounded())
        
        // Extract hours by dividing by the number of milliseconds in an hour.
        let hours = totalMilliseconds / 3_600_000
        
        // Extract minutes by using modulo to remove the hours part, then dividing by milliseconds per minute.
        let minutes = (totalMilliseconds % 3_600_000) / 60_000
        
        // Extract seconds by removing hours and minutes, then dividing by 1000.
        let seconds = (totalMilliseconds % 60_000) / 1000
        
        // The remaining value represents the milliseconds not forming a complete second.
        let milliseconds = totalMilliseconds % 1000
        
        // The use of String formatting ensures each time component has the desired width:
        // hours, minutes, and seconds are zero-padded to two digits, milliseconds to three.
        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    }
}


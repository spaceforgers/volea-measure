//
//  ExportManager.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 13/2/25.
//

import Foundation
import ZIPFoundation
import MeasureData

/// Manages the export of recorded sessions to a ZIP file with a structured folder layout.
/// The folder structure is:
///   - <ExportRoot>
///       - <HandType>
///           - <MovementType>
///               - movement_<movementID>.csv
@Observable
final class ExportManager {
    /// Exports an array of sessions into a ZIP file.
    /// - Parameter sessions: The sessions to export.
    /// - Returns: The URL of the generated ZIP file.
    /// - Throws: An error if any file operation or zipping fails.
    func export(sessions: Set<RecordingSession>) throws -> URL {
        let fileManager = FileManager.default
        
        // Create a temporary export directory
        let exportRoot = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: exportRoot, withIntermediateDirectories: true)
        
        // Process each session
        for session in sessions {
            guard let movements = session.movements else { continue }
            
            for movement in movements {
                // Get the folder names from hand and movement type.
                let handFolderName = movement.handType.rawValue
                let movementFolderName = movement.movementType.rawValue
                
                // Build the directory path: <exportRoot>/<handFolderName>/<movementFolderName>
                let handFolderURL = exportRoot.appendingPathComponent(handFolderName)
                let movementFolderURL = handFolderURL.appendingPathComponent(movementFolderName)
                
                // Create directories if they don't exist
                if !fileManager.fileExists(atPath: handFolderURL.path) {
                    try fileManager.createDirectory(at: handFolderURL, withIntermediateDirectories: true)
                }
                if !fileManager.fileExists(atPath: movementFolderURL.path) {
                    try fileManager.createDirectory(at: movementFolderURL, withIntermediateDirectories: true)
                }
                
                // Build a file name for the CSV file
                let fileName = "movement_\(UUID().uuidString).csv"
                let fileURL = movementFolderURL.appendingPathComponent(fileName)
                
                // Generate CSV content for this movement
                let csvContent = createCSV(for: movement)
                try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date.now)
        
        // Create the ZIP file in a temporary location.
        let zipFileURL = exportRoot.deletingLastPathComponent().appendingPathComponent("export_\(dateString).zip")
        try fileManager.zipItem(at: exportRoot, to: zipFileURL)
        
        return zipFileURL
    }
    
    /// Generates a CSV string for a given movement.
    /// The CSV includes a header and one row per motion data sample.
    /// - Parameter movement: The movement to export.
    /// - Returns: A CSV-formatted string.
    private func createCSV(for movement: RecordingMovement) -> String {
        // Define CSV header columns
        let header = "index,timestamp,sensorTimestamp,relativeTimestamp,userAccX,userAccY,userAccZ,rotRateX,rotRateY,rotRateZ,attitudePitch,attitudeRoll,attitudeYaw,quatX,quatY,quatZ,quatW,gravityX,gravityY,gravityZ,magFieldX,magFieldY,magFieldZ"
        
        // Ensure there is motion data available
        guard let motionDataList = movement.motionData, !motionDataList.isEmpty else {
            return header
        }
        
        let sortedData = motionDataList.sorted { $0.index < $1.index }
        
        // Build a CSV row for each motion data sample.
        let rows = sortedData.map { data in
            return "\(data.index),\(data.timestamp),\(data.sensorTimestamp),\(data.relativeTimestamp),\(data.userAccelerationX),\(data.userAccelerationY),\(data.userAccelerationZ),\(data.rotationRateX),\(data.rotationRateY),\(data.rotationRateZ),\(data.attitudePitch),\(data.attitudeRoll),\(data.attitudeYaw),\(data.attitudeQuaternionX),\(data.attitudeQuaternionY),\(data.attitudeQuaternionZ),\(data.attitudeQuaternionW),\(data.gravityX),\(data.gravityY),\(data.gravityZ),\(data.magneticFieldX),\(data.magneticFieldY),\(data.magneticFieldZ)"
        }
        
        // Combine the header and rows into a single CSV string.
        return ([header] + rows).joined(separator: "\n")
    }
}


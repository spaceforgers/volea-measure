//
//  SessionDetailView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 26/10/24.
//

import SwiftUI
import MeasureData

/// A view displaying the details of a recording session.
///
/// This view shows the session's timestamp and the associated movements. Movements are
/// presented in a list with navigation links, allowing users to tap through for more details.
/// The view also supports deletion of movements using swipe actions.
struct SessionDetailView: View {
    // MARK: - Environment
    
    /// Provides the model context for performing persistent data operations.
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    
    /// The recording session whose details are displayed.
    var session: RecordingSession
    
    // MARK: - Body
    
    var body: some View {
        List {
            // MARK: Session Information
            
            Section {
                // Display the session's timestamp with a calendar icon.
                Label(session.timestamp.formatted(.dateTime), systemImage: "calendar")
            }
            
            // MARK: Recorded Movements
            
            Section {
                // Safely unwrap and sort the movements (most recent first).
                if let movements = session.movements?.sorted(by: { $0.timestamp > $1.timestamp }),
                   !movements.isEmpty {
                    ForEach(movements) { movement in
                        NavigationLink(value: movement) {
                            VStack(alignment: .leading) {
                                // Display the movement timestamp.
                                Label(movement.timestamp.formatted(date: .omitted, time: .complete), systemImage: "clock")
                                // Display the hand used for the movement.
                                Label(movement.handType.label, systemImage: "hand.wave")
                                    .symbolVariant(.fill)
                                // Display the type of movement.
                                Label(movement.movementType.label, systemImage: "tennis.racket")
                                // Display the count of motion data samples.
                                Label("\(movement.motionData?.count ?? 0) motion data", systemImage: "circle.dotted.and.circle")
                            }
                        }
                    }
                    // Enable swipe-to-delete functionality.
                    .onDelete(perform: deleteMovements)
                    
                } else {
                    // Show a placeholder view when no movements are recorded.
                    ContentUnavailableView("No recorded movements", systemImage: "figure.tennis")
                }
            } header: {
                Text("Recorded movements")
            }
        }
        .navigationBarTitle("Session Details")
        .toolbar {
            // Toolbar items can be added here if needed.
        }
    }
    
    // MARK: - Data Management
    
    /// Deletes the movements at the specified offsets.
    ///
    /// - Parameter offsets: The indices of the movements to delete.
    private func deleteMovements(_ offsets: IndexSet) {
        do {
            for index in offsets {
                // Safely retrieve the movement at the current index.
                guard let movement = session.movements?[index] else { continue }
                modelContext.delete(movement)
            }
            // Persist changes to the model context.
            try modelContext.save()
        } catch {
            // Log any errors that occur during deletion.
            print("Error deleting movements: \(error)")
        }
    }
}

#Preview {
    // Preview the view with an empty session instance.
    SessionDetailView(session: .init())
}

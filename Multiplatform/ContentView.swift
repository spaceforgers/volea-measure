//
//  ContentView.swift
//  Volea Measure
//
//  Created by Javier Galera Robles on 3/8/24.
//

import SwiftUI
import SwiftData
import MeasureData

/// The main view for displaying a list of recording sessions.
///
/// This view leverages SwiftData’s `@Query` to fetch sessions from the persistent store,
/// while using SwiftUI’s `NavigationStack` to enable navigation to detailed views.
/// It also provides toolbar actions for exporting and creating new sessions.
struct ContentView: View {
    // MARK: - Environment and Data Dependencies
    
    /// The model context used for CRUD operations against the persistent store.
    @Environment(\.modelContext) private var modelContext
    
    /// A delegate for managing phone session-related events.
    /// Its exact responsibilities are abstracted, but it likely handles session connectivity.
    @Environment(PhoneSessionDelegate.self) private var sessionDelegate
    
    /// Query that fetches all `RecordingSession` objects, sorted by timestamp (most recent first).
    @Query(sort: \RecordingSession.timestamp, order: .reverse) private var sessions: [RecordingSession]
    
    /// Controls the presentation of the new session creation view.
    @State private var isNewSessionPresented: Bool = false
    
    // MARK: - View Body
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Records")
                .toolbar {
                    // Toolbar with an Export button on the leading side.
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Export") {
                            // TODO: Implement the export functionality.
                        }
                    }
                    
                    // Toolbar with an Add button on the trailing side.
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add", systemImage: "plus") {
                            isNewSessionPresented.toggle()
                        }
                    }
                }
                // Navigation destinations that enable deep linking:
                // one for session details and another for movement details.
                .navigationDestination(for: RecordingSession.self, destination: SessionDetailView.init)
                .navigationDestination(for: RecordingMovement.self, destination: SessionMovementDetailView.init)
        }
        // Presents a full-screen cover for creating a new recording session.
        .fullScreenCover(isPresented: $isNewSessionPresented, content: RecordingSessionView.init)
    }
    
    // MARK: - Subviews
    
    /// The primary content that displays a list of recording sessions.
    @ViewBuilder
    private var content: some View {
        List {
            // Iterates over the sessions retrieved by the query.
            ForEach(sessions) { session in
                NavigationLink(value: session) {
                    VStack(alignment: .leading) {
                        // Displays the session's timestamp, formatted for clarity.
                        Text(session.timestamp.formatted(date: .numeric, time: .shortened))
                        // Displays the count of movements in the session; defaults to 0 if not available.
                        Text("\(session.movements?.count ?? 0) moves")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Enables swipe-to-delete functionality on the list.
            .onDelete(perform: deleteSessions)
        }
    }
    
    // MARK: - Data Management Actions
    
    /// Deletes the selected sessions from the persistent store.
    ///
    /// - Parameter offsets: The indices of the sessions in the list to be deleted.
    ///
    /// This method iterates through the offsets, deletes the corresponding sessions from
    /// the model context, and then saves the context. Errors during the save are logged.
    private func deleteSessions(at offsets: IndexSet) {
        do {
            // Delete each session at the provided indices.
            for index in offsets {
                modelContext.delete(sessions[index])
            }
            // Save the changes to persist the deletion.
            try modelContext.save()
        } catch {
            // Log any errors encountered during deletion.
            print(error)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

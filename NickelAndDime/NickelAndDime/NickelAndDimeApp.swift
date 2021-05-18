//
//  NickelAndDimeApp.swift
//  NickelAndDime
//
//  Created by Brian Sakhuja on 5/18/21.
//

import SwiftUI

@main
struct NickelAndDimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  SwiftCalApp.swift
//  SwiftCal
//
//  Created by Josafat Vicente Pérez on 31/1/23.
//

import SwiftUI

@main
struct SwiftCalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

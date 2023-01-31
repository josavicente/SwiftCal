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
            TabView{
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                StreakView()
                    .tabItem {
                        Label("Streak", systemImage: "swift")
                    }
            }
            
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

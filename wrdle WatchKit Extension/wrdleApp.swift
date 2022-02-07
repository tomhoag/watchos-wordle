//
//  wrdleApp.swift
//  wrdle WatchKit Extension
//
//  Created by Tom on 1/4/22.
//

import SwiftUI

@main
struct wrdleApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

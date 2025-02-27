//
//  LCVAPortalApp.swift
//  LCVAPortal
//
//  Created by Sun English on 11/11/24.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseFirestore

let db = Firestore.firestore()


class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug)

        return true
    }

    // Restrict orientation to portrait only
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Restrict iPads to portrait mode only
            return .portrait
        } else {
            // Restrict iPhones to portrait mode only
            return .portrait
        }
    }

}

@main
struct LCVAPortalApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        SupabaseConfig.setupEnvironment()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

//
//  Prayer_TimeApp.swift
//  Prayer Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//

import SwiftUI

@main
struct Prayerr_TimeApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerTimesManager = PrayerTimesManager()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if locationManager.location == nil {
                    OnboardingView()
                } else {
                    TabView {
                        PrayerTimesView()
                            .tabItem {
                                Label("Vakitler", systemImage: "house.fill")
                            }
                        
                        DhikrmaticView()
                            .tabItem {
                                Label("Zikirmatik", systemImage: "repeat")
                            }
                        
                        SettingsView()
                            .tabItem {
                                Label("Ayarlar", systemImage: "gearshape.fill")
                            }
                    }.onAppear {
                        // NotificationManager.shared.scheduleMaghribNotifications(prayerTimes: prayerTimesManager.prayerTimes)
                    }

                }
            }
            .preferredColorScheme(themeManager.isDark ? .dark : .light)
            .environmentObject(themeManager)
            .environmentObject(languageManager)
            .environmentObject(locationManager)
            .environmentObject(prayerTimesManager)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                themeManager.refreshTheme()
            }
        }
    }
}

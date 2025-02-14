//
//  Fasting_TimeApp.swift
//  Fasting Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//

import SwiftUI

@main
struct Fasting_TimeApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fastingTimesManager = FastingTimesManager()
    
    @Environment(\.scenePhase) private var scenePhase // ✅ Tema geçişlerini dinler

    var body: some Scene {
        WindowGroup {
            Group {
                if locationManager.location == nil {
                    OnboardingView()
                } else {
                    DashboardView()
                }
            }
            .preferredColorScheme(themeManager.isDark ? .dark : .light) // ✅ Tema değişimini uygula
            .environmentObject(themeManager)
            .environmentObject(languageManager)
            .environmentObject(locationManager)
            .environmentObject(fastingTimesManager)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                themeManager.refreshTheme() // ✅ Tema değişimini kontrol et
            }
        }
    }
}

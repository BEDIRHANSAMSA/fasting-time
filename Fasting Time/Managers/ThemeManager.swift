//
//  ThemeManager.swift
//  Fasting Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//


import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDark") var isDark: Bool = false // ✅ Doğrudan AppStorage ile yönetiliyor
    
    func toggleTheme() {
        isDark.toggle()
    }

    func refreshTheme() {
        // ✅ Tema değişimini zorla tetikle
        objectWillChange.send()
    }
}

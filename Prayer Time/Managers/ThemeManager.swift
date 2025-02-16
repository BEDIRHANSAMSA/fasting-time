import SwiftUI

class ThemeManager: ObservableObject {
    private let appGroupID = "group.com.bedirhansamsa.prayerTime.data"
    private let themeKey = "theme"

    @Published var isDark: Bool

    init() {
        // ✅ `self` kullanmadan önce direkt değeri al
        let storedTheme = UserDefaults(suiteName: appGroupID)?.bool(forKey: themeKey) ?? false
        
        // ✅ `self` kullanarak `Published` değişkenini başlat
        _isDark = Published(initialValue: storedTheme)
    }

    func toggleTheme() {
        isDark.toggle()
        saveThemeToSharedStorage(isDark) // ✅ Shared Storage'a kaydet
    }

    func refreshTheme() {
        objectWillChange.send()
    }

    /// **📤 Shared Storage'a temayı kaydet**
    private func saveThemeToSharedStorage(_ isDark: Bool) {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(isDark, forKey: themeKey)
        defaults?.synchronize()
        
        print("🌙 Tema Kaydedildi: \(isDark ? "Karanlık" : "Açık")")
    }
}

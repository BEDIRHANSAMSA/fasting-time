import Foundation

enum Language: String {
    case english = "en"
    case turkish = "tr"
}

enum LocalizedKey {
    case dashboard
    case settings
    case language
    case appearance
    case darkMode
    case location
    case changeLocation
    case turkish
    case english
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            saveLanguageToSharedStorage(currentLanguage.rawValue) // ✅ Shared Storage'a kaydet
        }
    }
    
    private let appGroupID = "group.com.bedirhansamsa.prayerTime.data" // ✅ Shared App Group ID
    private let languageKey = "language" // ✅ Shared Storage anahtarı
    
    private let translations: [Language: [LocalizedKey: String]] = [
        .english: [
            .dashboard: "Dashboard",
            .settings: "Settings",
            .language: "Language",
            .appearance: "Appearance",
            .darkMode: "Dark Mode",
            .location: "Location",
            .changeLocation: "Change Location",
            .turkish: "Turkish",
            .english: "English"
        ],
        .turkish: [
            .dashboard: "Ana Sayfa",
            .settings: "Ayarlar",
            .language: "Dil",
            .appearance: "Görünüm",
            .darkMode: "Karanlık Mod",
            .location: "Konum",
            .changeLocation: "Konum Değiştir",
            .turkish: "Türkçe",
            .english: "İngilizce"
        ]
    ]
    
    init() {
        // ✅ Önce UserDefaults'tan dili çekiyoruz
        let savedLanguage = UserDefaults(suiteName: appGroupID)?.string(forKey: languageKey) ??
                            Locale.current.language.languageCode?.identifier ??
                            "en"
        
        // ✅ `self` kullanmadan direkt `currentLanguage`'i başlat
        _currentLanguage = Published(initialValue: Language(rawValue: savedLanguage) ?? .english)
    }
    
    func t(_ key: LocalizedKey) -> String {
        return translations[currentLanguage]?[key] ?? translations[.english]?[key] ?? ""
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
    
    /// **📥 Shared Storage'dan dili yükle (Artık Gerek Yok, `init()` İçinde Direkt Kullanılıyor)**
    private func loadLanguageFromSharedStorage() -> String? {
        return UserDefaults(suiteName: appGroupID)?.string(forKey: languageKey)
    }

    /// **📤 Shared Storage'a dili kaydet**
    private func saveLanguageToSharedStorage(_ language: String) {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(language, forKey: languageKey)
        defaults?.synchronize()
        
        print("🌍 Dil Kaydedildi: \(language)") // ✅ Konsolda görebilirsin
    }
}

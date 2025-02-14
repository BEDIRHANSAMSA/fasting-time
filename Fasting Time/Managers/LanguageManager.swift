//
//  Language.swift
//  Fasting Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//


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
    // Add other keys as needed
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "language")
        }
    }
    
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
        let savedLanguage = UserDefaults.standard.string(forKey: "language") ?? Locale.current.language.languageCode?.identifier
        self.currentLanguage = Language(rawValue: savedLanguage ?? "en") ?? .english
    }
    
    func t(_ key: LocalizedKey) -> String {
        return translations[currentLanguage]?[key] ?? translations[.english]?[key] ?? ""
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
}

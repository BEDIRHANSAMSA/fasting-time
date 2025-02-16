import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimesManager: PrayerTimesManager

    var body: some View {
        VStack {
            Form {
                // 🌍 **Konum Bilgisi**
                Section(header: Text("Konum")) {
                    if let location = locationManager.location {
                        VStack(alignment: .leading) {
                            Text("\(location.district.name.titleCase), \(location.city.name.titleCase)")
                                .font(.headline)
                            Text(location.country.name.titleCase)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Konumu Değiştir") {
                        locationManager.clearLocation()
                        prayerTimesManager.clearPrayerTimes()
                    }
                }

                // 🌓 **Tema Seçimi**
                Section(header: Text("Tema")) {
                    Toggle("Karanlık Mod", isOn: Binding(
                        get: { themeManager.isDark },
                        set: { newValue in
                            themeManager.toggleTheme() // ✅ Tema değişikliğini kaydet
                        }
                    ))
                }

                // 🌐 **Dil Seçimi**
                Section(header: Text("Dil")) {
                    Picker("Dil Seçimi", selection: $languageManager.currentLanguage) {
                        Text("Türkçe").tag(Language.turkish)
                        Text("English").tag(Language.english)
                    }
                    .pickerStyle(.inline)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(LocationManager())
}

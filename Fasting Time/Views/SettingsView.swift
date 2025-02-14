import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss // ✅ **Yeni dismiss yöntemi**

    var body: some View {
        NavigationView {
            Form {
                // 🌍 **Konum Bilgisi**
                Section(header: Text("Konum")) {
                    if let location = locationManager.location {
                        VStack(alignment: .leading) {
                            Text("\(location.district.name), \(location.city.name)")
                                .font(.headline)
                            Text(location.country.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Konumu Değiştir") {
                        locationManager.clearLocation()
                    }
                }

                // 🌓 **Tema Seçimi**
                Section(header: Text("Tema")) {
                    Toggle("Karanlık Mod", isOn: Binding(
                        get: { themeManager.isDark },
                        set: { newValue in
                            themeManager.isDark = newValue
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
            .navigationTitle("Ayarlar")
            .navigationBarItems(trailing: Button(action: {
                dismiss() // ✅ **Yeni dismiss fonksiyonu**
            }) {
                Text("Kapat")
                    .fontWeight(.semibold)
            })
        }
        .id(themeManager.isDark) // ✅ **Tema değişince direkt güncellenmesi için**
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(LocationManager())
}

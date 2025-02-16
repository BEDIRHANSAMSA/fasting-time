import SwiftUI

struct CountrySelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    let countries: [Location.Country] = CountryData.countries

    var filteredCountries: [Location.Country] {
        if searchText.isEmpty {
            return countries
        }
        return countries.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // ✅ **Başlık ve Alt Başlık**
            VStack(spacing: 6) {
                Text("🌍 Ülkeni Seç")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Bulunduğun ülkeyi seçerek devam et")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
            
            // ✅ **Düzenlenmiş Arama Çubuğu**
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Ülke ara", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            .padding(.horizontal, 16)
            
            // ✅ **Liste Alanı (Öğeler büyütüldü)**
            List {
                ForEach(filteredCountries) { country in
                    NavigationLink(destination: CitySelectionView(country: country)) {
                        HStack {
                            Text(country.code.flagEmoji)
                                .font(.system(size: 28)) // ✅ **Bayrak daha büyük**
                            
                            Text(country.name)
                                .font(.body.bold()) // ✅ **Ülke adı daha büyük ve kalın**
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14) // ✅ **Öğeler daha geniş**
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets()) // ✅ **Varsayılan boşluğu sıfırla**
                    .padding(.horizontal, 8) // ✅ **Kenarlardan biraz boşluk bırak**
                }
            }
            .listStyle(PlainListStyle())
            
            // ✅ **Diyanet Uyarı Metni**
            Text("Uygulamadaki tüm vakit bilgileri, Diyanet İşleri Başkanlığı tarafından sağlanan resmi verilere dayanmaktadır.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 10)
        }
        .navigationTitle("")

    }
}

#Preview {
    NavigationView {
        CountrySelectionView()
            .environmentObject(ThemeManager())
            .environmentObject(LanguageManager())
    }
}

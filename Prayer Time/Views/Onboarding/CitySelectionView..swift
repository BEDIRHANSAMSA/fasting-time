import SwiftUI

struct CitySelectionView: View {
    let country: Location.Country
    @State private var cities: [Location.City] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var error: Error?
    @EnvironmentObject var themeManager: ThemeManager

    var filteredCities: [Location.City] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // ✅ **Başlık ve Alt Başlık**
            VStack(spacing: 6) {
                Text("\(country.code.flagEmoji) Şehrini Seç")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(country.name) ülküesinde yaşadığın şehri seçerek bir sonraki adıma geç.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)

            // ✅ **Arama Çubuğu**
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Şehir ara", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            .padding(.horizontal, 16)

            // ✅ **Liste Alanı**
            List {
                ForEach(filteredCities) { city in
                    NavigationLink(destination: DistrictSelectionView(country: country, city: city)) {
                        HStack {
                            Text(city.name.titleCase)
                                .font(.body.bold()) // **Şehir adı büyütüldü**
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14) // ✅ **Öğeler daha geniş**
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, 8)
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
        .task {
            await loadCities()
        }
    }

    private func loadCities() async {
        isLoading = true
        error = nil

        do {
            let url = URL(string: "https://ezanvakti.emushaf.net/sehirler/\(country.id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            cities = try JSONDecoder().decode([Location.City].self, from: data)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}

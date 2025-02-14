//
//  District.swift
//  Fasting Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//

import SwiftUI

struct DistrictSelectionView: View {
    let country: Location.Country
    let city: Location.City
    @State private var districts: [Location.District] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var error: Error?
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimesManager: FastingTimesManager


    var filteredDistricts: [Location.District] {
        if searchText.isEmpty {
            return districts
        }
        return districts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // ✅ **Başlık ve Alt Başlık**
            VStack(spacing: 6) {
                Text("🏘️ İlçeni Seç")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Son olarak, \(city.name.titleCase) ilinde bulunduğun ilçeyi seç. Eğer bulunduğun ilçe gözükmüyorsa. Aynı İl seçebilirsin.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)

            // ✅ **Arama Çubuğu**
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("İlçe ara", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            .padding(.horizontal, 16)

            // ✅ **Liste Alanı**
            List {
                ForEach(filteredDistricts) { district in
                    Button {
                        selectDistrict(district)
                    } label: {
                        HStack {
                            Text(district.name)
                                .font(.body.bold()) // **İlçe adı büyütüldü**
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14)
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
        .navigationTitle("Şehir Seç")
        .task {
            await loadDistricts()
        }
    }
    private func loadDistricts() async {
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "https://ezanvakti.emushaf.net/ilceler/\(city.id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            districts = try JSONDecoder().decode([Location.District].self, from: data)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func selectDistrict(_ district: Location.District) {
        let location = Location(
            country: country,
            city: city,
            district: district
        )
        
        locationManager.setLocation(location)
        Task {
            await prayerTimesManager.fetchFastingTimes(for: district.id)
        }
    }
}

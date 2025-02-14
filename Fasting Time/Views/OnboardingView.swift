import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var isDetectingLocation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Temaya duyarlı arka plan
                themeManager.isDark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 32) {
                    Spacer()

                    // ✅ **Onboarding Görseli (Alternatif olarak özel bir resim kullanılabilir)**
                    Image(systemName: "sun.and.horizon.fill") // Güneş ve ufuk simgesi (imsak ve iftar vakitlerine gönderme yapıyor)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(themeManager.isDark ? .white.opacity(0.8) : .blue)

                    // ✅ **Başlık**
                    Text("Oruç Vakitleri")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.isDark ? .white : .primary)

                    // ✅ **Açıklama**
                    Text("Bulunduğun konuma göre imsak ve iftar vakitlerini öğren. Oruç takibini kolaylaştır.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(themeManager.isDark ? Color.white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 20)

                    Spacer()

                    if locationManager.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Konum tespit ediliyor...")
                                .foregroundColor(themeManager.isDark ? Color.white.opacity(0.8) : .secondary)
                                .padding(.top)
                        }
                    } else {
                        VStack(spacing: 16) {
                            // ✅ **Otomatik Konum Algılama Butonu**
                            Button(action: {
                                locationManager.requestLocation()
                            }) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Konumumu Algıla")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.isDark ? Color.blue.opacity(0.7) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // ✅ **Manuel Ülke Seçimi Butonu**
                            NavigationLink(destination: CountrySelectionView()) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Ülkeyi Manuel Seç")
                                        .frame(maxWidth: .infinity)
                                }
                                .padding()
                                .background(themeManager.isDark ? Color.white.opacity(0.1) : Color.secondary.opacity(0.1))
                                .foregroundColor(themeManager.isDark ? Color.white : .primary)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    // ✅ **Bilgilendirme Metni**
                    Text("Uygulamadaki tüm vakit bilgileri, Diyanet İşleri Başkanlığı tarafından sağlanan resmi verilere dayanmaktadır.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                }
                .padding(.vertical, 50)
            }
            .alert("Konum Algılandı", isPresented: $locationManager.showLocationConfirmation) {
                Button("Hayır", role: .cancel) {
                    locationManager.rejectLocation()
                }
                Button("Evet") {
                    locationManager.confirmLocation()
                }
            } message: {
                if let detected = locationManager.detectedLocation {
                    Text("Konumun: \(detected.district.name), \(detected.city.name), \(detected.country.name). Doğru mu?")
                        .foregroundColor(themeManager.isDark ? .white : .primary)
                }
            }
            .alert("Konum Hatası", isPresented: .constant(locationManager.error != nil)) {
                Button("Tamam") {
                    locationManager.error = nil
                }
            } message: {
                if let error = locationManager.error {
                    Text(error.localizedDescription)
                        .foregroundColor(themeManager.isDark ? .white : .primary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
        .environmentObject(LocationManager())
}

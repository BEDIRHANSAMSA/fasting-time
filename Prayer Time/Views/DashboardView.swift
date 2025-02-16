import SwiftUI
import ActivityKit

struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var prayerTimesManager: PrayerTimesManager
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🌙 Hoş Geldin")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            if let location = locationManager.location {
                HStack(spacing: 8) {
                    Text(location.country.code.flagEmoji)
                        .font(.title3)
                    VStack(alignment: .leading) {
                        Text(location.district.name.titleCase)
                            .font(.headline)
                            .bold()
                        Text("\(location.city.name.titleCase), \(location.country.name.titleCase)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            } 

            if prayerTimesManager.isLoading {
                ProgressView("Veriler Yükleniyor...")
                    .padding()
            }
            else if let error = prayerTimesManager.error {
                ErrorView(message: error.localizedDescription)
            }
            else if let todayPrayer = prayerTimesManager.prayerTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formattedToday() }) {
                CountdownTimer(prayerTime: todayPrayer) // 🔥 Yalnızca en yakın vakti gösterir
                    .padding(.horizontal)
            }
            else {
                VStack(spacing: 12) {
                    Text("Veri bulunamadı, güncelleniyor...")
                        .foregroundColor(.secondary)
                    
                    ProgressView()
                        .padding()
                }
                .onAppear {
                    Task {
                        await prayerTimesManager.fetchPrayerTimes(for: locationManager.location?.district.id ?? "0")
                    }
                }
                
            }
            Spacer()
        }
        .padding(.top, 12)
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func formatIsoDate(_ isoDate: String) -> String {
        if let formattedDate = isoDate.split(separator: "T").first {
            return String(formattedDate)
        }
        return "--"
    }
}

struct CountdownTimer: View {
    let prayerTime: PrayerTime
    @State private var targetTime: Date = Date()
    @State private var nextPrayerLabel: String = "" // 🔥 Hangi vakit olduğunu saklar

    var body: some View {
        VStack(spacing: 4) {
            Text(nextPrayerLabel) // 🔥 "İftara Kalan Süre" veya "Sahura Kalan Süre"
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(targetTime, style: .timer) // iOS'un kendi .timer formatı
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.blue)
                .monospacedDigit()
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            updateTargetTime()
        }
    }
    
    private func updateTargetTime() {
        let now = Date()
        let iftarTime = getTimeFromString(prayerTime.maghrib)
        let imsakTime = getTimeFromString(prayerTime.fajr, isNextDay: now >= iftarTime)

        if now >= iftarTime {
            targetTime = imsakTime
            nextPrayerLabel = "Sahura Kalan Süre" // 🔥 İftar geçmişse sahur vakti hesaplanır
        } else {
            targetTime = iftarTime
            nextPrayerLabel = "İftara Kalan Süre" // 🔥 İftara kalan süre hesaplanır
        }
    }

    private func getTimeFromString(_ timeString: String, isNextDay: Bool = false) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let dateTimeString = "\(today) \(timeString)"
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        var date = formatter.date(from: dateTimeString) ?? Date()
        
        if isNextDay {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return date
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Hata")
                .font(.headline)
                .foregroundColor(.primary)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
}

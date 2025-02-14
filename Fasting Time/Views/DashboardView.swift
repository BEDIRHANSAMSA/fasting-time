import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var fastingTimesManager: FastingTimesManager
    @State private var showSettings = false // ✅ Ayarlar sayfası için state

    var body: some View {
        VStack(spacing: 16) {
            // 🏠 **Hoş Geldin Mesajı**
            HStack {
                Text("🌙 Hoş Geldin")
                    .font(.title2) // Daha minimal
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showSettings = true // ✅ Ayarlar sayfasını aç
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // 🌍 **Konum Bilgisi**
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

            // 🔄 **Veri Yükleme Durumu**
            if fastingTimesManager.isLoading {
                ProgressView("Veriler Yükleniyor...")
                    .padding()
            }
            else if let error = fastingTimesManager.error {
                ErrorView(message: error.localizedDescription)
            }
            else if let todayFasting = fastingTimesManager.fastingTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formattedToday() }) {
                // ⏳ **Canlı Sayaç**
                CountdownTimer(fastingTime: todayFasting)
                    .padding(.horizontal)

                // 📋 **Günlük Vakit Listesi**
                FastingTimesList(fastingTime: todayFasting)
                    .padding(.horizontal)
            }
            else {
                VStack {
                    Text("Bugünün vakitleri bulunamadı.")
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                    Button("Verileri Güncelle") {
                        Task {
                            await fastingTimesManager.fetchFastingTimes(for: locationManager.location?.district.id ?? "0")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            Spacer()
        }
        .padding(.top, 12)
        .navigationTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) { // ✅ Ayarlar sayfasını açar
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
    let fastingTime: FastingTime
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 4) {
            Text(getCountdownLabel())
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatRemainingTime(remainingTime))
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.blue)
                .monospacedDigit()
                .animation(.easeInOut, value: remainingTime) // 🎯 **Animasyonlu sayaç**
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            updateRemainingTime()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func getCountdownLabel() -> String {
        return isBeforeIftar() ? "İftara Kalan Süre" : "Sahura Kalan Süre"
    }
    
    private func updateRemainingTime() {
        let now = Date()
        let iftarTime = getTimeFromString(fastingTime.maghrib)
        let imsakTime = getTimeFromString(fastingTime.fajr).addingTimeInterval(24 * 60 * 60)

        if now < iftarTime {
            remainingTime = iftarTime.timeIntervalSince(now)
        } else {
            remainingTime = imsakTime.timeIntervalSince(now)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                updateRemainingTime()
            }
        }
    }
    
    private func isBeforeIftar() -> Bool {
        return Date() < getTimeFromString(fastingTime.maghrib)
    }
    
    private func getTimeFromString(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let dateTimeString = "\(today) \(timeString)"
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.date(from: dateTimeString) ?? Date()
    }
    
    private func formatRemainingTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return "\(hours) saat \(minutes) dakika"
        } else if minutes > 0 {
            return "\(minutes) dakika"
        } else {
            return "\(seconds) saniye"
        }
    }
}

struct FastingTimesList: View {
    let fastingTime: FastingTime

    var body: some View {
        VStack(spacing: 12) {
            ForEach([
                ("İmsak", fastingTime.fajr),
                ("Güneş", fastingTime.sunrise),
                ("Öğle", fastingTime.dhuhr),
                ("İkindi", fastingTime.asr),
                ("Akşam", fastingTime.maghrib),
                ("Yatsı", fastingTime.isha)
            ], id: \.0) { (name, time) in
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Text(time)
                        .font(.title3)
                        .bold()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
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

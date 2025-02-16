import SwiftUI

struct PrayerTimesView: View {
    @EnvironmentObject var prayerTimesManager: PrayerTimesManager
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var selectedDate = Date()
    @State private var remainingTime: TimeInterval = 0
    @State private var nextPrayer: String = ""
    @State private var currentPrayer: String = ""

    var body: some View {
        VStack {
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
            
            VStack(spacing: 16) {
                            
                // 🔹 En Yakın Namaz Vaktine Kalan Süre
                VStack(spacing: 4) {
                    Text("\(currentPrayer)")
                        .font(.headline)

                }
                .padding()

                
                // 🔹 En Yakın Namaz Vaktine Kalan Süre
                VStack(spacing: 4) {
                    Text("\(nextPrayer) vaktine")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    
                    Text(formatRemainingTime(remainingTime))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .monospacedDigit()
                        .animation(.snappy, value: remainingTime)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                                
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        updateRemainingTime()
                    }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 32, height: 32) // 🔹 Daha dengeli bir boyut
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(formattedDateWithDay(selectedDate))
                        .font(.system(size: 16, weight: .semibold)) // 🔹 Daha küçük font
                        .padding(.vertical, 8) // 🔹 Daha az dikey padding
                        .padding(.horizontal, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8) // 🔹 Daha az yuvarlatılmış köşeler
                        .onTapGesture {
                            withAnimation {
                                selectedDate = Date()
                                updateRemainingTime()
                            }
                        }

                    Spacer()

                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        updateRemainingTime()
                    }) {
                        Image(systemName: "chevron.right")
                            .frame(width: 32, height: 32) // 🔹 Daha dengeli bir boyut
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 10) // 🔹 Yan boşlukları artırarak sıkışıklığı önleme
                
                // 🔹 Namaz Vakitleri Listesi (Şu Anki Vakit Animasyonlu)
                if let prayerTime = prayerTimesManager.prayerTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formatIsoDateFromDate(selectedDate) }) {
                    
                    let isFriday = Calendar.current.component(.weekday, from: selectedDate) == 6 // Cuma günü mü?
                    
                    let prayerTimes = [
                        ("İmsak", prayerTime.fajr, "İmsak"),
                        ("Güneş", prayerTime.sunrise, "Güneş"),
                        (isFriday ? "Öğle 🕌" : "Öğle", prayerTime.dhuhr, "Öğle"), // 🔥 Cuma kontrolü
                        ("İkindi", prayerTime.asr, "İkindi"),
                        ("Akşam", prayerTime.maghrib, "Akşam"),
                        ("Yatsı", prayerTime.isha, "Yatsı")
                    ]
                    
                    VStack(spacing: 10) {
                        ForEach(prayerTimes, id: \.0) { (displayName, time, originalName) in
                            HStack {
                                Text(displayName) // Cuma günleri "Öğle 🕌" gösterilir
                                    .font(.headline)
                                    .foregroundColor(currentPrayer == originalName ? .white : .primary)
                                
                                Spacer()
                                
                                Text(time)
                                    .font(.title3)
                                    .bold()
                                    .animation(.spring(duration: 0.5), value: currentPrayer)
                                    .foregroundColor(currentPrayer == originalName ? .white : .primary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(currentPrayer == originalName ? Color.blue : Color(.systemGray6))
                                    .animation(.easeInOut(duration: 0.5), value: currentPrayer)
                            )
                        }
                    }
                } else {
                    Text("Bu tarih için veri bulunamadı.")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
            }
            .padding()
            .navigationTitle("Namaz Vakitleri")
            .onAppear {
                updateRemainingTime()
                startTimer()
            }
        }
    }
    
    private func updateRemainingTime() {
        DispatchQueue.main.async {
            let now = Date()
            
            if let prayerTime = prayerTimesManager.prayerTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formatIsoDateFromDate(selectedDate) }) {
                let times = [
                    ("İmsak", prayerTime.fajr, "İmsak"),
                    ("Güneş", prayerTime.sunrise, "Güneş"),
                    ("Öğle", prayerTime.dhuhr, "Öğle"),
                    ("İkindi", prayerTime.asr, "İkindi"),
                    ("Akşam", prayerTime.maghrib, "Akşam"),
                    ("Yatsı", prayerTime.isha, "Yatsı")
                ]
                
                var previousPrayer: String = ""
                
                for (_, time, originalName) in times {
                    let prayerTime = getTimeFromString(time)
                    if prayerTime > now {
                        nextPrayer = originalName // 🔥 Cuma günleri Öğle 🕌 yerine "Öğle" olarak tutulur
                        remainingTime = prayerTime.timeIntervalSince(now)
                        
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPrayer = previousPrayer // 🔥 Cuma günü de doğru çalışır
                        }
                        break
                    }
                    previousPrayer = originalName
                }
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    updateRemainingTime() // Süre bitince anında yeni vakti hesapla
                }
            }
        }
    }
    
    private func formattedDateWithDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR") // 🔥 Türkçe gün isimleri
        formatter.dateFormat = "EEEE, dd MMMM yyyy" // 🔥 Pazartesi, 12 Şubat 2025
        return formatter.string(from: date)
    }
    
    private func formatRemainingTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatIsoDate(_ isoDate: String) -> String {
        if let formattedDate = isoDate.split(separator: "T").first {
            return String(formattedDate)
        }
        return "--"
    }
    
    private func formatIsoDateFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func getTimeFromString(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let dateTimeString = "\(today) \(timeString)"
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.date(from: dateTimeString) ?? Date()
    }
}

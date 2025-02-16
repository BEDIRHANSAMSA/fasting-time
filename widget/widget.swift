import WidgetKit
import SwiftUI

struct PrayerCountdownEntry: TimelineEntry {
    let date: Date
    let targetTime: Date
    let label: String
    let countryFlag: String
    let cityName: String
    let prayerTime: String
}

struct Provider: TimelineProvider {
    private let appGroupID = "group.com.bedirhansamsa.prayerTime.data"

    func placeholder(in context: Context) -> PrayerCountdownEntry {
        let targetTime = Date().addingTimeInterval(3600)
        return PrayerCountdownEntry(
            date: Date(),
            targetTime: targetTime,
            label: "Sahura Kalan Süre",
            countryFlag: "🇹🇷",
            cityName: "İstanbul",
            prayerTime: "--:--"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerCountdownEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerCountdownEntry>) -> Void) {
        let entry = createEntry()
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(30))) // ⏳ 30 saniyede bir yenile
        completion(timeline)
    }

    /// 📌 **JSON’dan Verileri Al**
    private func getPrayerTimes() -> [PrayerTime] {
        let defaults = UserDefaults(suiteName: appGroupID)
        let decoder = JSONDecoder()

        if let savedData = defaults?.data(forKey: "prayerTimes"),
           let decoded = try? decoder.decode([PrayerTime].self, from: savedData) {
            return decoded
        }
        return []
    }

    /// 🔥 **En Yakın Vakti Bul (Dashboard ile Aynı Mantık)**
    private func createEntry() -> PrayerCountdownEntry {
        let prayerTimes = getPrayerTimes()
        let now = Date()

        let todayPrayer = prayerTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formattedToday() })
        let tomorrowPrayer = prayerTimes.first(where: { formatIsoDate($0.gregorianLongIso) == formattedTomorrow() })

        guard let today = todayPrayer, let tomorrow = tomorrowPrayer else {
            return PrayerCountdownEntry(
                date: now,
                targetTime: now,
                label: "Veri Yok",
                countryFlag: "❌",
                cityName: "Bilinmiyor",
                prayerTime: "--:--"
            )
        }

        let iftarTime = getTimeFromString(today.maghrib)
        let imsakTime = getTimeFromString(tomorrow.fajr, isNextDay: true)

        /// ✅ **Dashboard ile Aynı Mantık**
        /// **Eğer şu an iftar vaktinden sonra ise, en yakın vakit sahurdur**
        let isAfterIftar = now >= iftarTime
        let nextPrayerTime = isAfterIftar ? imsakTime : iftarTime
        let label = isAfterIftar ? "Sahura Kalan Süre" : "İftara Kalan Süre"
        let prayerTime = isAfterIftar ? tomorrow.fajr : today.maghrib

        return PrayerCountdownEntry(
            date: now,
            targetTime: nextPrayerTime,
            label: label,
            countryFlag: "🇹🇷",
            cityName: "İstanbul",
            prayerTime: prayerTime
        )
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func formattedTomorrow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return formatter.string(from: tomorrow)
    }

    private func formatIsoDate(_ isoDate: String) -> String {
        return isoDate.split(separator: "T").first.map { String($0) } ?? "--"
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

struct WidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily  // Get widget size

    var body: some View {
        // Wrap the entire content in a Group
        Group {
            VStack(spacing: 4) {
                // 🌍 Country flag and city name (top)
                HStack(spacing: 5) {
                    Text(entry.countryFlag)
                        .font(.title2)
                    Text(entry.cityName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 5)

                Spacer()
                
                // 📌 Countdown Label and Timer (center)
                VStack(spacing: 4) {
                    Text(widgetFamily == .systemSmall ? shortLabel(entry.label) : entry.label)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    
                    Text(entry.targetTime, style: .timer)
                        .font(.system(size: widgetFamily == .systemSmall ? 18 : 24, weight: .bold))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()

                Text(entry.prayerTime)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.bottom, 5)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .applyWidgetContainerBackground() // Attach container background at the root
    }
    
    /// Function to shorten label for small widgets.
    func shortLabel(_ label: String) -> String {
        if label.contains("İftar") {
            return "İftar"
        } else if label.contains("Sahur") {
            return "Sahur"
        }
        return label
    }
}



struct widget: Widget {
    let kind: String = "widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Time")
        .description("Shows countdown to the next prayer.")
    }
}


extension View {
    /// Applies the required widget container background if available (iOS 17+), else falls back to a simple background.
    @ViewBuilder
    func applyWidgetContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            // The containerBackground modifier is required in iOS 17 widgets.
            self.containerBackground(for: .widget) {
                // Customize your background view if needed
                Color(.black)
            }
        } else {
            self.background(Color(.black))
        }
    }
}

#Preview(as: .systemSmall) {
    widget()
} timeline: {
    PrayerCountdownEntry(
        date: .now,
        targetTime: Date().addingTimeInterval(3600),
        label: "Sahura Kalan Süre",
        countryFlag: "🇹🇷",
        cityName: "İstanbul",
        prayerTime: "06:25"
    )
}

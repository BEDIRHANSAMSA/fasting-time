import ActivityKit
import WidgetKit
import SwiftUI

struct PrayerLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date          // Geri sayımın biteceği tam zaman
        var label: String          // "İftar" veya "Sahur"
        var countryFlag: String    // Ülke Bayrağı
        var cityName: String       // Şehir Adı
        var targetTime: String     // Hedef saat (örn: "18:46")
    }

    var name: String
}

struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerLiveActivityAttributes.self) { context in
            
            VStack(spacing: 8) {
                HStack(spacing: 5) {
                    Text(context.state.countryFlag)
                        .font(.title2)
                    Text(context.state.cityName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.top, 5)

                Spacer()
                
                // 📌 Vakit Başlığı ve ⏳ Geri Sayım (Ortada Sabit)
                VStack(spacing: 4) {
                    Text(context.state.label) // ✅ Küçük widgetta kısa metin
                         .font(.subheadline)
                         .foregroundColor(.blue)
                         .lineLimit(1)
                    
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()

                // 🕰️ Namaz Vakti Saati (En Alta Sabit)
                Text(context.state.targetTime)
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.bottom, 5)
            }
            .padding()
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // **Expanded UI (Büyütülmüş Görünüm)**
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.countryFlag)
                        .font(.title3)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.cityName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text(context.state.label)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text(context.state.endTime, style: .timer)  // ✅ **DÜZELTİLDİ**
                            .font(.system(size: 20, weight: .bold))
                            .monospacedDigit()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("🕰️ \(context.state.targetTime)")
                        .font(.footnote)
                        .bold()
                }
            } compactLeading: {
                Text(context.state.label == "İftar" ? "🌙" : "☀️")
            } compactTrailing: {
                Text(context.state.endTime, style: .timer)  // ✅ **DÜZELTİLDİ**
                    .font(.system(size: 14, weight: .bold))
            } minimal: {
                Text(context.state.endTime, style: .timer)  // ✅ **DÜZELTİLDİ**
                    .font(.system(size: 14, weight: .bold))
            }
        }
    }
}

// ✅ **Live Activity İçin Önizleme**
extension PrayerLiveActivityAttributes {
    fileprivate static var preview: PrayerLiveActivityAttributes {
        PrayerLiveActivityAttributes(name: "Prayer Time")
    }
}

extension PrayerLiveActivityAttributes.ContentState {
    fileprivate static var iftarPreview: PrayerLiveActivityAttributes.ContentState {
        PrayerLiveActivityAttributes.ContentState(
            endTime: Date().addingTimeInterval(3600),  // 🔥 **1 saat sonra bitiş**
            label: "İftar",
            countryFlag: "🇹🇷",
            cityName: "İstanbul",
            targetTime: "18:46"
        )
    }

    fileprivate static var sahurPreview: PrayerLiveActivityAttributes.ContentState {
        PrayerLiveActivityAttributes.ContentState(
            endTime: Date().addingTimeInterval(1800),  // 🔥 **30 dakika sonra bitiş**
            label: "Sahur",
            countryFlag: "🇹🇷",
            cityName: "İstanbul",
            targetTime: "05:10"
        )
    }
}


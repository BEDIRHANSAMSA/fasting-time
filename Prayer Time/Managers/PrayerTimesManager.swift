import Foundation
import WidgetKit

class PrayerTimesManager: ObservableObject {
    static let shared = PrayerTimesManager()
    @Published var prayerTimes: [PrayerTime] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let prayerKey = "prayerTimes"
    private let dateKey = "prayerTimesLastUpdate"
    private let appGroupID = "group.com.bedirhansamsa.prayerTime.data"

    init() {
        self.prayerTimes = loadPrayerTimes() ?? []
  
    }

    func fetchPrayerTimes(for districtId: String) async {
        if let cachedData = loadPrayerTimes(), isDataValid() {
            DispatchQueue.main.async {
                self.prayerTimes = cachedData
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }

        do {
            let url = URL(string: "https://ezanvakti.emushaf.net/vakitler/\(districtId)")!
            let (data, _) = try await URLSession.shared.data(from: url)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let fetchedData = try decoder.decode([PrayerTime].self, from: data)

            savePrayerTimes(fetchedData)

            DispatchQueue.main.async {
                self.prayerTimes = fetchedData
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async { 
                self.error = error
                self.isLoading = false
            }
            print("❌ JSON Hatası: \(error.localizedDescription)")
        }
    }

    private func savePrayerTimes(_ times: [PrayerTime]) {
        do {
            let defaults = UserDefaults(suiteName: appGroupID)
            let encoder = JSONEncoder()

            if let encoded = try? encoder.encode(times) {
                defaults?.set(encoded, forKey: prayerKey)
                defaults?.synchronize()
                print("📥 Widget JSON Kaydedildi")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("❌ Veri kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    func clearPrayerTimes() {
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.removeObject(forKey: prayerKey)
        prayerTimes = []
    }

    private func loadPrayerTimes() -> [PrayerTime]? {
        let defaults = UserDefaults(suiteName: appGroupID)
        let decoder = JSONDecoder()

        if let savedData = defaults?.data(forKey: prayerKey) {
            do {
                return try decoder.decode([PrayerTime].self, from: savedData)
            } catch {
                print("❌ Widget için JSON çözme hatası: \(error)")
            }
        }
        return nil
    }

    private func isDataValid() -> Bool {
        guard let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date else { return false }
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return savedDate > oneMonthAgo
    }
}

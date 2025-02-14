import Foundation

class FastingTimesManager: ObservableObject {
    @Published var fastingTimes: [FastingTime] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let fileName = "fastingTimes.json"
    private let dateKey = "fastingTimesLastUpdate"

    init() {
        self.fastingTimes = loadFastingTimes() ?? [] // ✅ `loadFastingTimes()` sonucu kullanıldı
    }

    /// **Önce kaydedilmiş veriyi kontrol et, sonra API’den çek**
    func fetchFastingTimes(for districtId: String) async {
        if let cachedData = loadFastingTimes(), isDataValid() {
            DispatchQueue.main.async { // ✅ Ana thread'e alındı
                self.fastingTimes = cachedData
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
            let fetchedData = try decoder.decode([FastingTime].self, from: data)

            saveFastingTimes(fetchedData)

            DispatchQueue.main.async {
                self.fastingTimes = fetchedData
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async { // ✅ Ana thread'e alındı
                self.error = error
                self.isLoading = false
            }
            print("❌ JSON Hatası: \(error.localizedDescription)")

        }
    }

    /// **Tüm oruç vakitlerini JSON olarak kaydet**
    private func saveFastingTimes(_ times: [FastingTime]) {
        do {
            let encodedData = try JSONEncoder().encode(times)
            let url = getFileURL()
            try encodedData.write(to: url, options: .atomic)
            UserDefaults.standard.set(Date(), forKey: dateKey)
        } catch {
            print("Veri kaydetme hatası: \(error.localizedDescription)")
        }
    }
    
    /// **Kayıtlı oruç vakitlerini yükle**
    private func loadFastingTimes() -> [FastingTime]? {
        let url = getFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([FastingTime].self, from: data)
        } catch {
            print("Kayıtlı veriyi yüklerken hata oluştu: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// **Kayıtlı veri 1 aydan eski mi?**
    private func isDataValid() -> Bool {
        guard let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date else { return false }
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return savedDate > oneMonthAgo
    }

    /// **Dosyanın kaydedileceği dizini döndür**
    private func getFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
}

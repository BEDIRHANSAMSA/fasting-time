import Foundation

extension String {
    var titleCase: String {
        let locale = Locale(identifier: "tr_TR") // Türkçe Locale kullan
        return self.components(separatedBy: " ")
            .map { $0.prefix(1).uppercased(with: locale) + $0.dropFirst().lowercased(with: locale) }
            .joined(separator: " ")
    }
    
    var flagEmoji: String {
        let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        
        var flag = ""
        for char in self.uppercased() {
            if let scalar = UnicodeScalar(base + UnicodeScalar(String(char))!.value) {
                flag.append(String(scalar))
            }
        }
        return flag
    }
}

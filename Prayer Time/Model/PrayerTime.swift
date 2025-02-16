//
//  PrayerTime.swift
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//

import Foundation

struct PrayerTime: Codable {
    let maghrib: String  // Akşam
    let moonPhaseURL: String  // Ayın Şekli URL
    let greenwichMeanTime: Double  // Greenwich Ortalama Zamanı
    let sunrise: String  // Güneş
    let sunset: String  // Güneş Batışı
    let sunRiseTime: String  // Güneş Doğuş
    let hijriShort: String  // Hicri Kısa Tarih
    let hijriShortIso: String?  // Hicri Kısa Tarih (ISO)
    let hijriLong: String  // Hicri Uzun Tarih
    let hijriLongIso: String?  // Hicri Uzun Tarih (ISO)
    let asr: String  // İkindi
    let fajr: String  // İmsak
    let qiblaTime: String  // Kıble Saati
    let gregorianShort: String  // Miladi Kısa Tarih
    let gregorianShortIso: String?  // Miladi Kısa Tarih (ISO)
    let gregorianLong: String  // Miladi Uzun Tarih
    let gregorianLongIso: String  // Miladi Uzun Tarih (ISO)
    let dhuhr: String  // Öğle
    let isha: String  // Yatsı

    enum CodingKeys: String, CodingKey {
        case maghrib = "Aksam"
        case moonPhaseURL = "AyinSekliURL"
        case greenwichMeanTime = "GreenwichOrtalamaZamani"
        case sunrise = "Gunes"
        case sunset = "GunesBatis"
        case sunRiseTime = "GunesDogus"
        case hijriShort = "HicriTarihKisa"
        case hijriShortIso = "HicriTarihKisaIso8601"
        case hijriLong = "HicriTarihUzun"
        case hijriLongIso = "HicriTarihUzunIso8601"
        case asr = "Ikindi"
        case fajr = "Imsak"
        case qiblaTime = "KibleSaati"
        case gregorianShort = "MiladiTarihKisa"
        case gregorianShortIso = "MiladiTarihKisaIso8601"
        case gregorianLong = "MiladiTarihUzun"
        case gregorianLongIso = "MiladiTarihUzunIso8601"
        case dhuhr = "Ogle"
        case isha = "Yatsi"
    }
}

//
//  LocationManager.swift
//  Fasting Time
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//


import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: Location?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var detectedLocation: (country: Location.Country, city: Location.City, district: Location.District)?
    @Published var showLocationConfirmation = false

    override init() {
        super.init()
        locationManager.delegate = self
        
        if let savedLocation = UserDefaults.standard.data(forKey: "location") {
            do {
                location = try JSONDecoder().decode(Location.self, from: savedLocation)
            } catch {
                print("Error loading saved location: \(error)")
            }
        }
    }
    
    func requestLocation() {
        isLoading = true
        error = nil
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("No location data received")
            return
        }
        print("Detected Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        fetchLocationDetails(for: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        self.isLoading = false
        print("Failed to get location: \(error.localizedDescription)")

    }
    
    private func fetchLocationDetails(for location: CLLocation) {
        Task {
            do {
                // 1. Önce Türkiye'nin şehirlerini al
                let citiesUrl = URL(string: "https://ezanvakti.emushaf.net/sehirler/2")!
                let (citiesData, _) = try await URLSession.shared.data(from: citiesUrl)
                let cities = try JSONDecoder().decode([Location.City].self, from: citiesData)
                
                // 2. Reverse geocoding ile şehri bul
                let geocoder = CLGeocoder()
                let locale = Locale(identifier: "tr_TR") // Türkçe Locale tanımla
                let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: locale)
                
                guard let placemark = placemarks.first,
                      let administrativeArea = placemark.administrativeArea else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not determine location"])
                }
                
                
                // 3. Şehri eşleştir
                guard let city = cities.first(where: { city in
                    city.name.localizedCaseInsensitiveContains(administrativeArea)
                }) else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "City not found in Turkey"])
                }
                
                // 4. İlçeleri al
                let districtsUrl = URL(string: "https://ezanvakti.emushaf.net/ilceler/\(city.id)")!
                let (districtsData, _) = try await URLSession.shared.data(from: districtsUrl)
                let districts = try JSONDecoder().decode([Location.District].self, from: districtsData)
                
                // 5. İlçeyi eşleştir
                let subLocality = placemark.subLocality ?? placemark.locality ?? ""
                let district = districts.first(where: { district in
                    district.name.localizedCaseInsensitiveContains(subLocality)
                }) ?? districts.first(where: { district in
                    district.name.localizedCaseInsensitiveContains(administrativeArea)
                })
                
                guard let selectedDistrict = district else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "District not found"])
                }
                
                // 6. Location'ı ayarla

                DispatchQueue.main.async {
                    self.detectedLocation = (
                        country: Location.Country(id: "2", name: "Türkiye", code: "TR"),
                        city: Location.City(id: city.id, name: city.name),
                        district: Location.District(id: selectedDistrict.id, name: selectedDistrict.name))
                    self.showLocationConfirmation = true
                }
                
            } catch {
                print("Failed to get location: \(error.localizedDescription)")
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func confirmLocation() {
        guard let detected = detectedLocation else { return }
        
        // Here you would typically make an API call to get the actual IDs
        // For now, we'll use placeholder values
        let location = Location(
            country: detectedLocation!.country,
            city: detectedLocation!.city,
            district: detectedLocation!.district
        )
        
        setLocation(location)
        showLocationConfirmation = false
        self.isLoading = false
    }
    
    func rejectLocation() {
        detectedLocation = nil
        showLocationConfirmation = false
    }

    
    func setLocation(_ newLocation: Location) {
        do {
            let data = try JSONEncoder().encode(newLocation)
            UserDefaults.standard.set(data, forKey: "location")
            location = newLocation
        } catch {
            print("Error saving location: \(error)")
        }
    }
    
    func clearLocation() {
        UserDefaults.standard.removeObject(forKey: "location")
        location = nil
    }
}

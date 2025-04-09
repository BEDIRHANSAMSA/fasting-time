import SwiftUI
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleIftarNotification(for maghribTime: String) {
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "İftar Vakti"
        content.body = "Allah kabul etsin, hayırlı iftarlar!"
        
        // Ses dosyasının adını buraya yazın (örnek: "iftar_topu.mp3")
        if let soundURL = Bundle.main.url(forResource: "iftar_topu", withExtension: "mp3") {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundURL.lastPathComponent))
        } else {
            content.sound = .default
        }
        
        // Convert maghrib time string to Date components
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let date = formatter.date(from: maghribTime) else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "iftar-notification",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        // ... existing view code ...
            .onAppear {
                // Request notification permission when view appears
                NotificationManager.shared.requestPermission()
                // Schedule notification for Maghrib time
                if let prayerTime = viewModel.prayerTimes.first {
                    NotificationManager.shared.scheduleIftarNotification(for: prayerTime.maghrib)
                }
            }
    }
} 
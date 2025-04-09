//
//  NotificationManager.swift
//  Prayer Time
//
//  Created by Bedirhan SAMSA on 1.03.2025.
//


import Foundation
import UserNotifications
import AVFoundation
import BackgroundTasks

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isNotificationsEnabled = false
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        checkNotificationStatus()
        registerBackgroundTask()
        setupNotifications()
    }
    
    private func setupNotifications() {
        requestAuthorization()
        sendTestNotification() // Test bildirimi
    }
    
    private func sendTestNotification() {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                print("❌ Bildirim izni istenmedi.")
            case .denied:
                print("❌ Bildirim izni reddedildi.")
            case .authorized, .provisional:
                print("✅ Bildirim izni verildi.")
            @unknown default:
                break
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Test Bildirimi"
        content.body = "Bildirimler çalışıyor! 🎉"
        content.sound = UNNotificationSound.default
        
        // 5 saniye sonra bildirim gönder
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let id = UUID().uuidString

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test bildirimi gönderilemedi: \(error.localizedDescription)")
            } else {
                print("✅ Test bildirimi gönderildi")
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending requests: \(requests)")
        }
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                if granted {
                    self.scheduleBackgroundRefresh()
                }
            }
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleMaghribNotifications(prayerTimes: [PrayerTime]) {
        // Remove existing notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Schedule notifications for the next 7 days
        for prayerTime in prayerTimes {
            scheduleSingleMaghribNotification(prayerTime: prayerTime)
        }
    }
    
    private func scheduleSingleMaghribNotification(prayerTime: PrayerTime) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "İftar Vakti Yaklaşıyor"
        content.body = "İftar vakti \(prayerTime.maghrib)'da"
        content.sound = UNNotificationSound.default
        
        // Parse prayer time and set notification 15 minutes before
        if let maghribTime = parseTime(timeString: prayerTime.maghrib, date: prayerTime.gregorianLongIso) {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: maghribTime)
            
            // Set notification 15 minutes before Maghrib
            if let minute = dateComponents.minute {
                dateComponents.minute = minute - 15
            }
            
            // Create trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Create request with unique identifier for each day
            let identifier = "maghrib_notification_\(prayerTime.gregorianLongIso)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            // Schedule notification
            notificationCenter.add(request) { error in
                if let error = error {
                    print("❌ Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func parseTime(timeString: String, date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(date) \(timeString)")
    }
    
    // Background task handling
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bedirhansamsa.prayerTime.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.bedirhansamsa.prayerTime.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // Refresh every hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("❌ Could not schedule app refresh: \(error)")
        }
    }
    
    // UNUserNotificationCenterDelegate methods
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
} 

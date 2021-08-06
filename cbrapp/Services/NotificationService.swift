//
//  NotificationService.swift
//  cbrapp
//
//  Created by Nikita Fedorenko on 06.08.2021.
//

import Foundation
import NotificationCenter

class NotificationService: NSObject {
    
    //static let shared = NotificationService()
    
    lazy var notificationCenter: UNUserNotificationCenter = {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        return center
    }()
    
    func requestAuth() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
            }
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "cbr_notification", content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .banner, .sound])
    }
}

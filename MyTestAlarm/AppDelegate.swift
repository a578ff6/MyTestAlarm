//
//  AppDelegate.swift
//  MyTestAlarm
//
//  Created by 曹家瑋 on 2023/11/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // 當 App 啟動完成後會被呼叫。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /// 當前的通知中心。
        let center = UNUserNotificationCenter.current()
        /// 創建了 Snooze 的貪睡動作。
        let snoozeAction = UNNotificationAction(identifier: Alarm.snoozeActionId, title: "Snooze", options: [])
        /// 通知類別，包含貪睡動作。
        let alarmCategory = UNNotificationCategory(identifier: Alarm.notificationCategoryId, actions: [snoozeAction], intentIdentifiers: [], options: [])
        /// 將通知類別設置到通知中心。
        center.setNotificationCategories([alarmCategory])
        center.delegate = self          // 將 AppDelegate 自己設置為通知中心的代理，以處理通知相關的事件。
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// 用於當通知被用戶操作時的處理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 檢查用戶操作的是不是"貪睡"動作
        if response.actionIdentifier == Alarm.snoozeActionId {
            
            // 設定貪睡時間為當前時間後的9分鐘
            let snoozeDate = Date().addingTimeInterval(9 * 60)
            
            // 建立一個新的鬧鐘，設定為上面計算的貪睡時間
            let alarm = Alarm(date: snoozeDate)
            // 排程這個新的鬧鐘
            alarm.schedule { granted in
                
                // 檢查是否獲得了通知權限
                if !granted {
                    print("Can't schedule snooze because notification permissions were revoked.")
                }
            }
        }
        
        completionHandler()         // 呼叫 completionHandler，告知已處理完畢
    }
    
    // 當通知即將在 App 前景（即 App 正在使用中）展示時被調用
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 設定通知的展示方式。
        completionHandler([.list, .banner, .sound])
        
        // 將 Alarm 的 scheduled 屬性設為 nil，表示目前沒有排程的鬧鐘
        // 這是因為通知即將展示，用戶可以設定一個新的鬧鐘
        Alarm.scheduled = nil
    }
    
    
}



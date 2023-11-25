//
//  Alarm.swift
//  MyTestAlarm
//
//  Created by 曹家瑋 on 2023/11/24.
//

import Foundation
import UserNotifications

struct Alarm {
    
    /// 通知的Id
    private var notificationId: String
    /// 鬧鐘觸發的日期和時間
    var date: Date
    
    /// 初始化一個鬧鐘實例
    init(notificationId: String? = nil, date: Date) {
        self.notificationId = notificationId ?? UUID().uuidString
        self.date = date
    }
    
    /// 排定鬧鐘通知。首先檢查通知授權狀態，如果已授權，則建立並排定一個通知。通知的內容包括標題、文字和聲音。
    /// 如果通知成功排定，則透過 completion handler 回傳 true；若排定失敗或沒有授權，則回傳 false。
    func schedule(completion: @escaping (Bool) -> ()) {
        
        authorizeIfNeeded { (granted) in
            // 檢查是否取得通知授權
            guard granted else {
                DispatchQueue.main.async {
                    completion(false)       // 沒有授權，回傳 false
                }
                
                return
            }
            
            /// 創建通知內容，設置標題、訊息和聲音
            let content = UNMutableNotificationContent()
            content.title = "Alarm"
            content.body = "Beep！Beep!"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Alarm.notificationCategoryId
            
            /// 設定觸發時間，不重複觸發
            let triggerDateComponents = Calendar.current.dateComponents([.minute, .hour, .day,. month, .year], from: self.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
            
            /// 創建通知請求並加入到通知中心
            let request = UNNotificationRequest(identifier: self.notificationId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)       // 發生錯誤，回傳 false
                    } else {
                        Alarm.scheduled = self  // 如果成功將鬧鐘加入 UNUserNotificationCenter
                        completion(true)        // 成功排定通知，回傳 true
                    }
                }
            }
        }
    }
    
    /// 取消已排定的鬧鐘通知
    func unschedule() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        // 當取消鬧鐘時設置 scheduled 為 nil
        Alarm.scheduled = nil
    }
    
    
    /// 用於必要時請求通知授權
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        /// 當前的通知中心
        let notificationCenter = UNUserNotificationCenter.current()
        /// 獲取當前的通知設置，並基於這些設置來確定授權狀態
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            // 如果授權狀態尚未確定，請求授權
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.sound, .alert], completionHandler: { (granted, _) in
                    completion(granted) // 授權結果回傳
                })
            // 如果已授權，直接回傳 true
            case .authorized:
                completion(true)
            // 如果被拒絕或其他狀態，回傳 false
            case .denied, .provisional, .ephemeral:
                completion(false)
            // 處理未知狀態
            @unknown default:
                completion(false)
            }
        }
    }
    
}

// MARK: - Alarm 擴展: 實現 Codable 並處理持久化儲存
extension Alarm: Codable {
    /// 通知類別的id，用於註冊和識別通知類別。
    static let notificationCategoryId = "AlarmNotification"
    /// 貪睡動作的id
    static let snoozeActionId = "snooze"
    
    /// 用於儲存鬧鐘的文件路徑。
    /// - Returns: 返回一個指向 documents 目錄中 "ScheduledAlarm" 文件的 URL。
    private static let alarmURL: URL = {
        guard let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Can't get URL for documents directory.")
        }
        
        return baseURL.appendingPathComponent("ScheduledAlarm")
    }()
    
    /// 用於獲取和設置計劃中的鬧鐘。
    /// - 使用 JSON 編解碼器從文件系統中讀取和寫入鬧鐘。
    static var scheduled: Alarm? {
        get {
            guard let data = try? Data(contentsOf: alarmURL) else {
                return nil
            }
            
            return try? JSONDecoder().decode(Alarm.self, from: data)
        }
        
        set {
            if let alarm = newValue {
                guard let data = try? JSONEncoder().encode(alarm) else {
                    return
                }
                
                try? data.write(to: alarmURL)
            } else {
                // 當 scheduled 被設置為 nil 時，移除儲存在 alarmURL 的任何數據。
                try? FileManager.default.removeItem(at: alarmURL)
            }
            
            // 發送通知，表示鬧鐘已更新。
            NotificationCenter.default.post(name: .alarmUpdated, object: nil)
        }
    }
}



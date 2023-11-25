//
//  Notifications.swift
//  MyTestAlarm
//
//  Created by 曹家瑋 on 2023/11/24.
//

import Foundation

/// 擴展 Notification.Name 以添加自定義的通知名稱。
extension Notification.Name {
    /// 當鬧鐘設置或取消時，可以使用這個名稱來發送和接收通知。
    static let alarmUpdated = Notification.Name("alarmUpdated")
}


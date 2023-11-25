//
//  ViewController.swift
//  MyTestAlarm
//
//  Created by 曹家瑋 on 2023/11/23.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()  // 更新使用者介面
        
        // 註冊通知，當鬧鐘更新時會觸發 updateUI 方法
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .alarmUpdated, object: nil)
    }
    
    // 當按下設置鬧鐘按鈕時執行的動作
    @IBAction func setAlarmButtonTapped(_ sender: UIButton) {
        if let alarm = Alarm.scheduled {
            // 如果鬧鐘已經設置，則取消它
            alarm.unschedule()
        } else {
            // 用選擇的日期創建新鬧鐘
            let alarm = Alarm(date: datePicker.date)
            alarm.schedule { [weak self] (permissionGranted) in
                if !permissionGranted {
                    self?.presentNeedAuthorizationAlert()   // 如果沒有通知權限，顯示警告
                }
            }
        }
    }
    
    /// 顯示一個警告視窗，提示用戶需要授予通知權限
    func presentNeedAuthorizationAlert() {
        let alert = UIAlertController(title: "Authorization Needed", message: "Alarms don't work without notifications, and it looks like you haven't granted us permission to send you those. Please go to the iOS Settings app and grant us notification permissions.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    /// 更新使用者介面的方法
    @objc func updateUI() {
        if let scheduledAlarm = Alarm.scheduled {
            // 格式化並顯示設定的鬧鐘時間
            let formattedAlarm = scheduledAlarm.date.formatted(.dateTime
                .day(.defaultDigits)
                .month(.defaultDigits)
                .year(.twoDigits)
                .hour().minute())
            
            alarmLabel.text = "Your alarm is scheduled for \(formattedAlarm)"
            datePicker.isEnabled = false
            scheduleButton.setTitle("Remove Alarm", for: .normal)
        } else {
            alarmLabel.text = "Set an alarm below"
            datePicker.isEnabled = true
            scheduleButton.setTitle("Set Alarm", for: .normal)
        }
    }
}

//
//  NotificationViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 4/1/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit

class DailyNotificationViewController: UIViewController {
    
    @IBOutlet weak var setTimeBtn: UIButton!
    @IBOutlet weak var removeTimeBtn: UIButton!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var hour = String()
    var min = String()
    var dateToDisplay = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetTimeButton()
        setupRemoveTimeButton()
        
        appDelegate?.registerForPushNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if let temp = request.trigger as? UNCalendarNotificationTrigger{
                    self.hour = String(temp.dateComponents.hour!)
                    self.min = String(temp.dateComponents.minute!)
                }
            }
            
            if(self.hour == "" || self.min == ""){
                DispatchQueue.main.async {
                    self.currentTimeLbl.text = "Not Set"
                    self.setRemoveDailyReminderBtn()
                }
            }else{
                if(self.hour != "" || self.min != ""){
                    self.dateToDisplay = self.formatTime(inHour: self.hour, inMin: self.min)
                    DispatchQueue.main.async {
                        self.currentTimeLbl.text = self.dateToDisplay
                        self.setRemoveDailyReminderBtn()
                    }
                }
            }
        })
    }

    @IBAction func SetTime(_ sender: Any) {
        let dateFormatter = DateFormatter()
        let calHour = Calendar.current.dateComponents([.hour], from: datePicker.date)
        let calMin = Calendar.current.dateComponents([.minute], from: datePicker.date)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "hh:mm a"
        currentTimeLbl.text = dateFormatter.string(from: datePicker.date)
        appDelegate?.scheduleDailyNotification(inHour: calHour.hour!, inMin: calMin.minute!)
        setRemoveDailyReminderBtn()
        dailyNotificationAddedAlert(title: "Daily Notification Set", message: "Daily notification set for \(currentTimeLbl.text!)", thisView: self)
    }
    
    func setupSetTimeButton(){
        setTimeBtn.layer.cornerRadius = 10
    }
    
    func setupRemoveTimeButton(){
        removeTimeBtn.layer.cornerRadius = 10
    }
    
    func formatTime(inHour: String, inMin: String)->String{
        let combined = "\(inHour):\(inMin)"
        let dateAsString = combined
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        let returnDate = dateFormatter.string(from: date!)
        return returnDate
    }
    
    @IBAction func RemoveTime(_ sender: Any) {
        appDelegate?.removeDailyNotification(identifier: "Daily Reminder")
        currentTimeLbl.text = "Not Set"
        setRemoveDailyReminderBtn()
        dailyNotificationRemovedAlert(title: "Daily Notificaiton Removed", message: "Daily notification for prayer has been removed.", thisView: self)
    }
    
    func setRemoveDailyReminderBtn(){
        
        if (currentTimeLbl.text == "Not Set"){
            removeTimeBtn.isHidden = true
        }else{
            removeTimeBtn.isHidden = false
        }
    }
}

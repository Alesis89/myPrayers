//
//  NotificationViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 4/1/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit
import UserNotifications

class DailyNotificationViewController: UIViewController {
    
    @IBOutlet weak var setTimeBtn: UIButton!
    @IBOutlet weak var removeTimeBtn: UIButton!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var hour = String()
    var min = String()
    var dateToDisplay = String()
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSetTimeButton()
        setupRemoveTimeButton()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.center.getPendingNotificationRequests(completionHandler: { requests in
                    
                    for request in requests {
                        if request.identifier == "Daily Alert"{
                            
                            if let temp = request.trigger as? UNCalendarNotificationTrigger{
                                self.hour = String(temp.dateComponents.hour!)
                                self.min = String(temp.dateComponents.minute!)
                                
                                self.dateToDisplay = self.formatTime(inHour: self.hour, inMin: self.min)
                                DispatchQueue.main.async {
                                    self.currentTimeLbl.text = self.dateToDisplay
                                    self.setRemoveDailyReminderBtn()
                                }
                                break
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.currentTimeLbl.text = "Not Set"
                                self.setRemoveDailyReminderBtn()
                            }
                        }
                    }
                })
            } else if let error = error {
                print(error.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    permissionDenied(title: "Permission Denied", message: "Permission has not been granted for notifications", thisView: self)
                }
            }
        }
    }

    @IBAction func SetTime(_ sender: Any) {
        
        currentTimeLbl.text = setDailyReminder(inDate: datePicker, completion: nil)
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
        center.removePendingNotificationRequests(withIdentifiers: ["Daily Alert"])
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

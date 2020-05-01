//
//  PrayerReminderTableViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 4/29/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit

class PrayerReminderTableViewController: UITableViewController{
    
    private var dateCellExpanded: Bool = false
    @IBOutlet weak var removeReminder: UIButton!
    @IBOutlet weak var setReminder: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lblPickerDate: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    let center = UNUserNotificationCenter.current()
    
    //set values coming in from prayer details
    var inPrayerKey: String!
    var inPrayerFor: String!
    var inPrayerMessage: String!
    
    var hour = String()
    var min = String()
    var month = String()
    var weekday = String()
    var year = String()
    
    var dateToDisplay = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set minimum date for picker
        datePicker.minimumDate = Date()
        
        //set table attributes
        tableView.backgroundColor = UIColor.init(red: 194/255, green: 194/255, blue: 223/255, alpha: 1.0)
        
        setReminder.layer.cornerRadius = 10
        removeReminder.layer.cornerRadius = 10
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.center.getPendingNotificationRequests(completionHandler: { requests in
                    for request in requests {
                        if request.identifier == self.inPrayerKey{
                            
                            if let temp = request.trigger as? UNCalendarNotificationTrigger{
                                self.hour = String(temp.dateComponents.hour!)
                                self.min = String(temp.dateComponents.minute!)
                                
                                if(temp.dateComponents.weekday != nil && request.trigger?.repeats == true){
                                    DispatchQueue.main.async {
                                        self.weekday = String(temp.dateComponents.weekday!)
                                        self.repeatLabel.text = "Weekly"
                                    }
                                }else if(temp.dateComponents.day != nil && temp.dateComponents.month == nil && request.trigger?.repeats == true){
                                    DispatchQueue.main.async {
                                        self.month = String(temp.dateComponents.day!)
                                        self.repeatLabel.text = "Monthly"
                                    }
                                }else if(temp.dateComponents.day != nil && temp.dateComponents.month != nil && request.trigger?.repeats == true){
                                    DispatchQueue.main.async {
                                        self.month = String(temp.dateComponents.month!)
                                        self.repeatLabel.text = "Yearly"
                                    }
                                }else if(request.trigger?.repeats == false){
                                    DispatchQueue.main.async {
                                        self.repeatLabel.text = "Never"
                                    }
                                }else{
                                    //must be a daily reminder
                                    DispatchQueue.main.async {
                                        self.repeatLabel.text = "Daily"
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.lblPickerDate.text = self.formatTime(inDate: temp.nextTriggerDate()!)
                                    self.setRemoveDailyReminderBtn()
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.lblPickerDate.text = "Not Set"
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
    
    func formatTime(inDate: Date)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/yyyy, hh:mm a"
        let returnDate = dateFormatter.string(from: inDate)
        return returnDate
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/yyyy, hh:mm a"
        lblPickerDate.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if dateCellExpanded {
                dateCellExpanded = false
            } else {
                dateCellExpanded = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }else if(indexPath.row == 1){
            let topVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
            let VC1 = topVC?.storyboard?.instantiateViewController(withIdentifier: "Repeat Reminder") as! RepeatReminderViewController
            VC1.modalPresentationStyle = .currentContext
            VC1.selectedRepeatDelegate = self
            VC1.title = "Repeat Options"
            VC1.inRepeatSetting = repeatLabel.text!
            topVC!.show(VC1, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if dateCellExpanded {
                return 250
            } else {
                return 50
            }
        }
        return 50
    }
    
    @IBAction func setReminderTapped(_ sender: Any) {
        
        if(lblPickerDate.text == "Not Set"){
            errorMessageAlert(title: "Error", message: "Please select a date.", thisView: self)
        }else{
            setPrayerReminder(inIdentifier: inPrayerKey, inPrayFor: inPrayerFor, inMessageBody: inPrayerMessage, inDate: datePicker, inRepeat: repeatLabel.text!) { (success) in
                if(success){
                    dailyNotificationAddedAlert(title: "Prayer Notification Set", message: "Prayer notification set for \(self.lblPickerDate.text!)", thisView: self)
                }
            }
        }
    }
    
    func setRemoveDailyReminderBtn(){
        
        if (lblPickerDate.text == "Not Set"){
            removeReminder.isHidden = true
        }else{
            removeReminder.isHidden = false
        }
    }
    
    @IBAction func removeReminderTapped(_ sender: Any) {
        center.removePendingNotificationRequests(withIdentifiers: [inPrayerKey])
        repeatLabel.text = "Not Set"
        setRemoveDailyReminderBtn()
        dailyNotificationRemovedAlert(title: "Prayer Notificaiton Removed", message: "Prayer notification has been removed.", thisView: self)
    }
}


extension PrayerReminderTableViewController: SelectedRepeatDelegate{
    func didSelectRepeat(repeatOption: String?) {
        repeatLabel.text = repeatOption!
    }
    
    
}

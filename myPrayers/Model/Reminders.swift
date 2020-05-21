//
//  Reminders.swift
//  myPrayers
//
//  Created by Bill Clark on 4/22/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

let center = UNUserNotificationCenter.current()

func setDailyReminder(inDate: UIDatePicker, completion: ((Bool)->Void)?)->String{
    
    var stringToReturn = ""
    let dateFormatter = DateFormatter()
    var dateComponents = DateComponents()

    //store hour and minute from picker
    dateComponents.hour = Calendar.current.dateComponents([.hour], from: inDate.date).hour
    dateComponents.minute = Calendar.current.dateComponents([.minute], from: inDate.date).minute

    //Setup formatting to display date in lable
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.dateFormat = "hh:mm a"
    stringToReturn = dateFormatter.string(from: inDate.date)

    let identifier = "Daily Alert"
    let content = UNMutableNotificationContent()
    content.title = "Daily Prayer Reminder"
    content.body = "Take time now to pray for those in your prayer list."
    content.categoryIdentifier = "alarm"
    content.sound = UNNotificationSound.default

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    center.add(request)
    completion?(true)
    
    return stringToReturn
    
}

func setPrayerReminder(inIdentifier: String, inPrayFor: String, inMessageBody: String, inDate: UIDatePicker, inRepeat: String, completion: ((Bool)->Void)?){
    
    var repeatAlert = false
    var dateComponents = DateComponents()

    //store hour and minute and repeat from picker
    
    switch inRepeat {
    case "Daily":
        repeatAlert = true
    case "Weekly":
        repeatAlert = true
        dateComponents.weekday  = Calendar.current.dateComponents([.weekday], from: inDate.date).weekday
    case "Monthly":
        repeatAlert = true
        dateComponents.day  = Calendar.current.dateComponents([.day], from: inDate.date).day
    case "Yearly":
        repeatAlert = true
        dateComponents.day  = Calendar.current.dateComponents([.day], from: inDate.date).day
        dateComponents.month  = Calendar.current.dateComponents([.month], from: inDate.date).month
    default:
        repeatAlert = false
        dateComponents.day  = Calendar.current.dateComponents([.day], from: inDate.date).day
        dateComponents.weekday  = Calendar.current.dateComponents([.weekday], from: inDate.date).weekday
    }
    
    //These values are always set no matter the repeat options
    dateComponents.hour = Calendar.current.dateComponents([.hour], from: inDate.date).hour
    dateComponents.minute = Calendar.current.dateComponents([.minute], from: inDate.date).minute

    let identifier = inIdentifier
    let content = UNMutableNotificationContent()
    content.title = "Prayer Reminder"
    content.subtitle = "Pray for \(inPrayFor)"
    content.body = inMessageBody
    content.categoryIdentifier = "alarm"
    content.sound = UNNotificationSound.default

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatAlert)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    center.add(request) { (error) in
        if error != nil{
            print(error!.localizedDescription)
        }
        
    }
    completion?(true)
}

func removePrayerReminder(inPrayerId: String){
    center.removePendingNotificationRequests(withIdentifiers: [inPrayerId])
}



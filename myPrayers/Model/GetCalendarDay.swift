//
//  GetCalendarDay.swift
//  myPrayers
//
//  Created by Bill Clark on 8/11/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation

func getCalendarDayForVOTD()->Int{
    let date = Date() // now
    let cal = Calendar.current
    let day = cal.ordinality(of: .day, in: .year, for: date)
    return day!
}

func getCurrentDateTime()->String{
    let date = Date()
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone.init(abbreviation: TimeZone.current.abbreviation()!)
    formatter.formatOptions.insert([.withTimeZone])
    
    return formatter.string(from: date)
}

func formatCalDayForCell(inDate: String)->String{
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let date = dateFormatter.date(from:inDate)!
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month, .day], from: date)
    
    let monthNumber = components.month
    let monthName = DateFormatter()
    monthName.dateFormat = "MM"
    let month = monthName.monthSymbols[monthNumber! - 1]
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .ordinal
    let ordinalDay = numberFormatter.string(from: components.day! as NSNumber)
    
    let retDate = "\(month) \(ordinalDay!)"
    
    return retDate
}

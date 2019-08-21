//
//  Prayer.swift
//  myPrayers
//
//  Created by Bill Clark on 8/16/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation

struct Prayer{
    var prayerKey = String()
    var createDateTime = String()
    var prayFor = String()
    var prayer = String()
    var userUID = String()
    
    init(prayerKey: String, createDateTime: String, prayFor: String, prayer: String, userID: String){
        self.prayerKey = prayerKey
        self.createDateTime = createDateTime
        self.prayFor = prayFor
        self.prayer = prayer
        self.userUID = userID
    }
}

//
//  PrayerTableViewCell.swift
//  myPrayers
//
//  Created by Bill Clark on 8/12/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit

class PrayerTableViewCell: UITableViewCell {
    var prayerKey = String()
    @IBOutlet weak var lblPrayFor: UILabel!
    @IBOutlet weak var lblPrayForText: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPrayer: UILabel!
    
}

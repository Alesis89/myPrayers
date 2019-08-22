//
//  ViewPrayerViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/22/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit

class ViewPrayerViewController: UIViewController {
    @IBOutlet weak var prayFor: UILabel!
    @IBOutlet weak var prayer: UITextView!
    
    var inPrayFor: String!
    var inPrayer: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Get prayer data that was passed in
        prayFor.text = inPrayFor
        prayer.text = inPrayer
    }

}

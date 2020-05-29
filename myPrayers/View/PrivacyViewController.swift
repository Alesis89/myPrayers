//
//  PrivacyViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 5/15/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIButton!
    
    var inPrivacySelection: String!
    var inCloseButtonNeeded = false
    var url:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (inCloseButtonNeeded){
            closeButton.isHidden = false
        }else{
            closeButton.isHidden = true
        }
        
        
        if (inPrivacySelection == "Privacy"){
            url = URL(string: "\(privacyTOSPolicies.privacyPolicy)")!
        }else if(inPrivacySelection == "TOS"){
            url = URL(string: "\(privacyTOSPolicies.tosPolicy)")!
        }else{
            url = URL(string: "\(privacyTOSPolicies.gitHubMyPrayers)")!
        }
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        // Do any additional setup after loading the view.
    }
    @IBAction func closeBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

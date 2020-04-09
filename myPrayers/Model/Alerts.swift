//
//  Alerts.swift
//  myPrayers
//
//  Created by Bill Clark on 8/12/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation
import UIKit

func errorMessageAlert(title: String, message: String, thisView: UIViewController){
    let topVC = thisView //UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(ok)
    topVC.present(alertController, animated: true, completion: nil)
}

func prayerAddedAlert(title: String, message: String, thisView: UIViewController){
    //let topVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.navigationController?.popToRootViewController(animated: true)
    }
    alertController.addAction(ok)
    thisView.present(alertController, animated: true, completion: nil)
}

func profileUpdatedAlert(title: String, message: String, thisView: UIViewController){
    //let topVC = UIApplication.shared.keyWindow?.rootViewController
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.navigationController?.popToRootViewController(animated: true)
    }
    alertController.addAction(ok)
    //topVC!.present(alertController, animated: true, completion: nil)
    thisView.present(alertController, animated: true, completion: nil)
}

func profileCreatedAlert(title: String, message: String, thisView: UIViewController){
    let topVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(ok)
    topVC!.present(alertController, animated: true, completion: nil)
}

func prayerModifiedAlert(title: String, message: String, thisView: UIViewController){
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.navigationController?.popToRootViewController(animated: true)
    }
    alertController.addAction(ok)
    thisView.present(alertController, animated: true, completion: nil)
}

func resetPasswordAlert(title: String, message: String, thisView: UIViewController){
    let topVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(ok)
    topVC!.present(alertController, animated: true, completion: nil)
}

func dailyNotificationAddedAlert(title: String, message: String, thisView: UIViewController){
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.navigationController?.popToRootViewController(animated: true)
    }
    alertController.addAction(ok)
    thisView.present(alertController, animated: true, completion: nil)
}

func dailyNotificationRemovedAlert(title: String, message: String, thisView: UIViewController){
    
    let alertController = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default){ (UIAlertAction) in
        thisView.navigationController?.popToRootViewController(animated: true)
    }
    alertController.addAction(ok)
    thisView.present(alertController, animated: true, completion: nil)
}

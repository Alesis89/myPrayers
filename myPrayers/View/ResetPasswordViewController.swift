//
//  ResetPasswordViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/26/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    
    var inEmailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(inEmailAddress != nil){
            email.text = inEmailAddress
        }
    }
    
    @IBAction func sendResetLink(_ sender: Any) {
        
        let result = isValidEmail(object: email)
        
        if (result){
            Auth.auth().sendPasswordReset(withEmail: email.text!) { (error) in
                if(error != nil){
                    errorMessageAlert(title: "Error", message: "Error Sending Email.  Please try again later.", thisView: self)
                }
                else{
                    resetPasswordAlert(title: "Email Sent!", message: "A reset passwword email has been sent", thisView: self)
                }
            }
        }else{
            errorMessageAlert(title: "Error!", message: "Not a valid email address", thisView: self)
            email.becomeFirstResponder()
        }
    }
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func isValidEmail(object: UITextField)->Bool {
        let testStr = object.text!
        if(object.accessibilityIdentifier == "confirmEmail" && object.text?.count == 0){
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        if result{
            //Valid email
            object.textColor = UIColor.init(red: 38.0/255, green: 150.0/255, blue: 92.0/255, alpha: 1.0)
            return true
        }else{
            //Not a valid email address
            object.textColor = UIColor.red
            errorMessageAlert(title: "Email Not Valid!", message: "Email address is not valid", thisView: self)
            object.becomeFirstResponder()
            return false
        }
    }
}

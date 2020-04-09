//
//  CreateAccountViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 4/3/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var errorMessageLbl: UILabel!
    
    var emailConfirmed = false
    var passwordConfirmed = false
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolbar()
        
        //Setup textfields to run function once user has left the control
        firstName.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        firstName.addTarget(self, action: #selector(isFieldValid), for: .editingDidEnd)
        lastName.addTarget(self, action: #selector(isFieldValid), for: .editingDidEnd)
        lastName.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        email.addTarget(self, action: #selector(isValidEmail), for: .editingDidEnd)
        email.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        confirmEmail.addTarget(self, action: #selector(isValidEmail), for: .editingDidEnd)
        confirmEmail.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        confirmEmail.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        //confirmPassword.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        password.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        confirmPassword.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        
        
        
        
        //Setup listener for keyboard.  This will allow for use to adjust view y axis in case keyboard covers a control
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification){
        
        
        //guard let keyboard = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            if(activeField?.accessibilityIdentifier == "confirmEmail"||activeField?.accessibilityIdentifier == "password" || activeField?.accessibilityIdentifier == "confirmPassword"){
                view.frame.origin.y = (-(activeField?.frame.origin.y)!)
            }
        }else{
            view.frame.origin.y = 0
        }
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexible = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexible,doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        firstName.inputAccessoryView = toolbar
        lastName.inputAccessoryView = toolbar
        email.inputAccessoryView = toolbar
        confirmEmail.inputAccessoryView = toolbar
        password.inputAccessoryView = toolbar
        confirmPassword.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        //Check to make sure all fields have been filled out.
        //Also, when checking email and password, make sure they match
        
        var errors = 0
        
        if (firstName.text?.count == 0){
            firstName.layer.borderColor = UIColor.red.cgColor
            firstName.layer.borderWidth = 1
            errors += 1
        }
        if(lastName.text?.count == 0){
            lastName.layer.borderColor = UIColor.red.cgColor
            lastName.layer.borderWidth = 1
            errors += 1
        }
        if(email.text?.count == 0){
            email.layer.borderColor = UIColor.red.cgColor
            email.layer.borderWidth = 1
            errors += 1
        }
        if(confirmEmail.text?.count == 0){
            confirmEmail.layer.borderColor = UIColor.red.cgColor
            confirmEmail.layer.borderWidth = 1
            errors += 1
        }else if(emailConfirmed == false){
            errorMessageAlert(title: "Email Error", message: "Please confirm your email address", thisView: self)
        }
        if(password.text?.count == 0){
            password.layer.borderColor = UIColor.red.cgColor
            password.layer.borderWidth = 1
            errors += 1
        }else{
            
            //Confirm password fields match
            textFieldChanged(object: confirmPassword)
            if(confirmPassword.text?.count == 0){
                confirmPassword.layer.borderColor = UIColor.red.cgColor
                confirmPassword.layer.borderWidth = 1
                errors += 1
            }else if (passwordConfirmed == false){
                errorMessageAlert(title: "Password Error", message: "Please confirm your password", thisView: self)
                errors += 1
            }
        }
        
        let displayName = "\(firstName.text!) \(lastName.text!)"
        
        //setup activity indicator
       let activity = UIActivityIndicatorView(style: .gray)

       activity.translatesAutoresizingMaskIntoConstraints = false
       activity.startAnimating()
       view.addSubview(activity)
       activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        if(errors > 0){
            errorMessageLbl.isHidden = false
        }else{

            //Auth display name is both first and last.,  Need to concatenate these two values before storing
            Auth.auth().createUser(withEmail: confirmEmail.text!, password: confirmPassword.text!) { (result, error) in
                if(result != nil){
                    Auth.auth().currentUser?.setValue(displayName, forKey: "displayName")
                    
                    //update CoreData
                    activity.startAnimating()
                    self.saveDataToCoreData(inDisplayName: displayName) { (result) in
                        if(result){
                            activity.stopAnimating()
                            profileCreatedAlert(title: "Profile Created!", message: "Profile succesfully created!", thisView: self)
                            activity.stopAnimating()
                        }else{
                            activity.stopAnimating()
                            errorMessageAlert(title: "Error!", message: "Error creating profile!", thisView: self)
                            activity.stopAnimating()
                        }
                    }
                }
                if(error != nil){
                    print(error?.localizedDescription as Any)
                }
            }
        }
        activity.stopAnimating()
    }
    
    func saveDataToCoreData(inDisplayName: String, completion: (Bool)->()){
        
        //Get reference to the Entity VOTD
        let context = DataController.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newValue = NSManagedObject(entity: entity!, insertInto: context)
        
        //Set data to the referenced entity attributes
        //newValue.setValue(mainDelegate.userImage.jpegData(compressionQuality: 1.0), forKey: "image")
        newValue.setValue(inDisplayName, forKey: "displayName")
        //newValue.setValue(profileImage.image!.jpegData(compressionQuality: 1.0), forKey: "image")
        
        //save data into attributes
        do{
            try context.save()
            completion(true)
            print("Saved Data!")
        }catch{
            completion(false)
            print("Failed to save data!")
        }
    }
    
    @objc func isValidEmail(object: UITextField) {
        let testStr = object.text!
        if(object.accessibilityIdentifier == "confirmEmail" || object.accessibilityIdentifier == "email" && object.text?.count == 0){
            return
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        if result{
            //Valid email
            object.textColor = UIColor.init(red: 38.0/255, green: 150.0/255, blue: 92.0/255, alpha: 1.0)
        }else{
            //Not a valid email address
            object.textColor = UIColor.red
            errorMessageAlert(title: "Email Not Valid!", message: "Email address is not valid", thisView: self)
        }
    }
    
    @objc func isFieldValid(object: UITextField) {
        
        if (object.text!.count > 0){
            //Valid field
            object.textColor = UIColor.init(red: 38.0/255, green: 150.0/255, blue: 92.0/255, alpha: 1.0)
        }
    }
    
    @objc func setActiveField(object: UITextField) {
        
        activeField = object
    }
    
    @objc func textFieldChanged(object: UITextField){
        switch object.accessibilityIdentifier {
        case "confirmEmail":
            if(object.text!.count > 0 && object.text != email.text){
                saveButton.isEnabled = false
                object.becomeFirstResponder()
                errorMessageAlert(title: "Email Mismatch", message: "Email Addresses don't match.", thisView: self)
                return
            }else{
                saveButton.isEnabled = true
                emailConfirmed = true
                return
            }
        case "confirmPassword":
            if(object.text!.count > 0 && object.text != password.text){
                saveButton.isEnabled = false
                object.becomeFirstResponder()
                errorMessageAlert(title: "Password Mismatch", message: "Passwords don't match.", thisView: self)
                return
            }else{
                saveButton.isEnabled = true
                passwordConfirmed = true
                print("before")
                return
            }
        default:
            return
        }
    }
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

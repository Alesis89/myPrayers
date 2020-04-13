//
//  LoginViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/4/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseStorage
import LocalAuthentication
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var createAccountButton: UIButton!
    var activeField: UITextField?
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    var userId: String!
    var bioImage = UIImageView()
    let bioButton = UIButton()
    let storedUserName = KeychainWrapper.standard.string(forKey: "userName")
    let storedUserPassword = KeychainWrapper.standard.string(forKey: "userPwd")
    let checkBio = UserDefaults.standard.value(forKey: "SET BIOMETRICS") as? Bool
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolbar()
        setupLoginButton()
        setupPasswordImage()
        
        userEmail.addTarget(self, action: #selector(setActiveField(object:)), for: .editingDidBegin)
        
        //check if biometric option off in the app.  If so, do not run biometric option
        if (checkBio == false || checkBio == nil){
            //do not run any biometric options.  Show login form as is.
            bioButton.isHidden = true
        }else{
            
            bioMetricLogin()
            setupBioButton()
        }
        
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
        
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            if(activeField?.accessibilityIdentifier == "userPassword"){
                
                view.frame.origin.y = (-(activeField?.frame.origin.y)!)
                
            }
        }else{
            view.frame.origin.y = 0
        }
    }
    
    @objc func setActiveField(object: UITextField) {
        
        activeField = object
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (checkBio == true && storedUserName != nil){
            bioButton.isHidden = false
        }else{
            bioButton.isHidden = true
        }
    }

    func setupLoginButton(){
        login.layer.cornerRadius = 10
    }
    
    func setupPasswordImage(){
        userPassword.rightViewMode = .always
        userPassword.rightView = bioButton
    }
    
    func setupBioButton(){
        bioButton.setImage(bioImage.image, for: .normal)
        bioButton.addTarget(self, action: #selector(faceIdTapped), for: .touchUpInside)
        //push the button off the edge of the textfield
        bioButton.contentEdgeInsets.right = 10
        bioButton.contentEdgeInsets.left = -10
    }
    
    @objc func faceIdTapped(_ sender: Any) {
        bioMetricLogin()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        if(userEmail.text?.count != 0 || userPassword.text?.count != 0){
            if checkBio == true {
                storeCredsinKeyChain()
            }
            loginUser(userName: userEmail.text!, userPassword: userPassword.text!)
        }else{
            errorMessageAlert(title: "Error!", message: "Error logging in, please check credentials", thisView: self)
        }
    }
    
    func storeCredsinKeyChain(){
        
        let _: Bool = KeychainWrapper.standard.set(self.userPassword.text!, forKey: "userPwd")
        let _: Bool = KeychainWrapper.standard.set(self.userEmail.text!, forKey: "userName")
  
    }
    
    func loginUser(userName: String!, userPassword: String!){
        
        //setup activity indicator
        let activity = UIActivityIndicatorView(style: .gray)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //MARK - Verify credentials
               Auth.auth().signIn(withEmail: "\(userName!)", password: "\(userPassword!)") { [weak self] user, error in
                   if (user != nil){
                       self!.userId = user?.user.uid
                       
                        //clear login and password for security reasons after being authenticated.
                        self!.userEmail.text = nil
                        self!.userPassword.text = nil
                    
                        //Save credentials to Keychain for auto login with biometrics later
                        let _: Bool = KeychainWrapper.standard.set((self!.userEmail.text!), forKey: "userEmail")
                        let _: Bool = KeychainWrapper.standard.set((self!.userPassword.text!), forKey: "userPassword")
                       
                       //Check coredata for user info.  Core data values should be present if user previously logged in.
                       self!.getDataFromCoreDataUser { (result) in
                           if(result){
                            
                            let nc = self?.storyboard?.instantiateViewController(withIdentifier: "Nav Controller") as! UINavigationController
                            nc.modalPresentationStyle = .fullScreen
                            self?.present(nc, animated: true, completion: nil)

                           }else{
                               
                               //Save user info to Core data
                               self!.mainDelegate.displayName = user!.user.displayName
                               self!.downloadUserProfileImage(userID: self!.userId, completion: { (result) in
                                   if (result){
                                       self!.saveData()
                                   }
                               })
                            
                            let nc = self?.storyboard?.instantiateViewController(withIdentifier: "Nav Controller") as! UINavigationController
                            nc.modalPresentationStyle = .fullScreen
                            self?.present(nc, animated: true, completion: nil)
                           }
                       }
                   }else{
                       errorMessageAlert(title: "Error Logging In", message: "\(error!.localizedDescription)", thisView: self!)
                   }
                   activity.stopAnimating()
               }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let VC1 = self.storyboard?.instantiateViewController(withIdentifier: "Reset Password") as! ResetPasswordViewController
        VC1.inEmailAddress = userEmail.text
        self.present(VC1, animated: true, completion: nil)
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        let VC1 = self.storyboard?.instantiateViewController(withIdentifier: "Create Account") as! CreateAccountViewController
        self.present(VC1, animated: true, completion: nil)
    }
    

    //Create a toolbar for the keyboard so that we can show a "done" button for the user to dismiss keyboard
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexible = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexible,doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        userEmail.inputAccessoryView = toolbar
        userPassword.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }
    
    //Save Image, Verse, Calendar day to Core Data
    func saveData(){
        
        //Get reference to the Entity VOTD
        let context = DataController.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newValue = NSManagedObject(entity: entity!, insertInto: context)
        
        //Set data to the referenced entity attributes
        //newValue.setValue(mainDelegate.userImage.jpegData(compressionQuality: 1.0), forKey: "image")
        newValue.setValue(mainDelegate.displayName, forKey: "displayName")
        if(mainDelegate.userImage != nil){
            newValue.setValue(mainDelegate.userImage.jpegData(compressionQuality: 1.0), forKey: "image")
        }
        
        //save data into attributes
        do{
            try context.save()
        }catch{
        }
    }
    
    func getDataFromCoreDataUser(completion: (Bool)->Void){
        
        //Check core data to see if we already have the VOTD image, verse, and calendar day for today's calendar day.
        //If so, we don't need to make another api call.
        
        let context = DataController.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        //Get data from coreData if exists
        do{
            let result = try context.fetch(request)
            
            if result.count > 0{
                for data in result as! [NSManagedObject]{
                    mainDelegate.displayName = data.value(forKey: "displayName") as? String
                    if (data.value(forKey: "image") != nil){
                        let profilePic = UIImage(data: data.value(forKey: "image") as! Data)
                         mainDelegate.userImage = profilePic
                    }else{
                        let profilePic = UIImage(named: "profile_pic_default")
                        mainDelegate.userImage = profilePic
                    }
                }
                completion(true)
                return
            }else{
                completion(false)
                return
            }
        }catch{
            completion(false)
            return
        }
    }
    
    func downloadUserProfileImage(userID: String, completion: @escaping (Bool)->Void){
        
        var userProfileImage: UIImage!
        
        let imagePath = Storage.storage().reference(withPath: "\(userID)/profile_pic.jpg")
        
        imagePath.getData(maxSize: 10000000) { (data, error) in
            if(error != nil){
                let profilePic = UIImage(named: "profile_pic_default")
                self.mainDelegate.userImage = profilePic
                completion(true)
            }else{
                userProfileImage = UIImage(data: data!)
                self.mainDelegate.userImage = userProfileImage
                completion(true)
            }
        }
    }
    
    
    
    //Check to see if the user has enable biometerics on the device itself.
    @objc func bioMetricLogin(){
        let context:LAContext = LAContext()
        //check to make sure we have stored credentials.
        if(storedUserName != nil && storedUserPassword != nil){
            //Login with users credentials.
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil ){
                let reason = "Log in to your account"
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "\(reason)") { (success, error) in
                    if(success){
                        DispatchQueue.main.async {
                            self.loginUser(userName: self.storedUserName, userPassword: self.storedUserPassword)
                        }
                    }else{
                        //errorMessageAlert(title: "Error", message: error!.localizedDescription, thisView: self)
                    }
                }
                
                if context.biometryType == LABiometryType.faceID{
                    bioImage.image =  UIImage(named: "face-id")!
                }else{
                    if context.biometryType == LABiometryType.touchID{
                        bioImage.image = UIImage(named: "fingerprint")!
                    }
                }
            }
        }
    }
}

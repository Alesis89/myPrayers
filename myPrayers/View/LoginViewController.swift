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

class LoginViewController: UIViewController {
    
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    var userId: String!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolbar()
    }

    @IBAction func btnLogin(_ sender: Any) {
        
        //setup activity indicator
        let activity = UIActivityIndicatorView(style: .gray)
        
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        //MARK - Verify credentials
        Auth.auth().signIn(withEmail: "\(userEmail.text!)", password: "\(userPassword.text!)") { [weak self] user, error in
            if (user != nil){
                self!.userId = user?.user.uid
                
                //Check coredata for user info.  Core data values should be present if user previously logged in.
                self!.getDataFromCoreDataUser { (result) in
                    if(result){
                        //Open app to nav controller
                        let VC1 = self?.storyboard?.instantiateViewController(withIdentifier: "Nav Controller") as! UINavigationController
                        self!.present(VC1, animated: true, completion: nil)
                    }else{
                        
                        //Save user info to Core data
                        self!.mainDelegate.displayName = user!.user.displayName
                        self!.downloadUserProfileImage(userID: self!.userId, completion: { (result) in
                            if (result){
                                self!.saveData()
                            }
                        })
                        
                        let VC1 = self?.storyboard?.instantiateViewController(withIdentifier: "Nav Controller") as! UINavigationController
                        self!.present(VC1, animated: true, completion: nil)
                    }
                }
            }else{
                errorMessageAlert(title: "Error Logging In", message: "\(error!.localizedDescription)", thisView: self!)
            }
            activity.stopAnimating()
        }
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
            print("Saved Data!")
        }catch{
            print("Failed to save data!")
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
            print("Failed to get data!")
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
            } else {
                userProfileImage = UIImage(data: data!)
                self.mainDelegate.userImage = userProfileImage
                completion(true)
                }
        }
    }
    
}

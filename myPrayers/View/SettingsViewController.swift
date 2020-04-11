//
//  SettingsViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/20/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import CoreData

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmEmail: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    
    let overlayImageView = UIImageView(frame: CGRect(x: 75, y: 50, width: 60, height: 50))
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //keep track of values that have changed
    var imageChanged = false
    var fnChanged = false
    var lnChanged = false
    var emailChanged = false
    
    
    //variables for passed information
    var inImage = UIImage()
    var inFN = String()
    var inLN = String()
    var inEmail = String()
    
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup Profile Image
        setupProfileImage()
        setupSaveButton()
        setupResetPasswordButton()
        firstName.text = inFN
        lastName.text = inLN
        email.text = inEmail
        
        firstName.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        lastName.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        email.addTarget(self, action: #selector(selectAllText), for: .editingDidBegin)
        email.addTarget(self, action: #selector(isValidEmail), for: .editingDidEnd)
        confirmEmail.addTarget(self, action: #selector(isValidEmail), for: .editingDidEnd)
        confirmEmail.addTarget(self, action: #selector(textFieldChanged(object:)), for: .editingDidEnd)
        
        //create toolbar with Done option so user can close keyboard
        createToolbar()
        
        //add the camera to right side of navigation tool bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraImageTapped))
    }
    
    func setupSaveButton(){
        saveButton.layer.cornerRadius = 10.0
    }
    
    func setupResetPasswordButton(){
        resetPasswordButton.layer.cornerRadius = 10.0
    }

    @IBAction func saveButton(_ sender: Any) {
        
        //setup activity indicator
        let activity = UIActivityIndicatorView(style: .gray)
        
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //Save data that was changed
        
        let imagePath = Storage.storage().reference(withPath: "\(userID!)/profile_pic.jpg")
        
        imagePath.putData((profileImage.image?.jpegData(compressionQuality: 1.0))!, metadata: nil, completion: {(metadata, error) in
            if error != nil{
                errorMessageAlert(title: "Error Uploading Image", message: "Error uploading image.  Try again later.", thisView: self)
            }else{
                //update appdelegate
                self.mainDelegate.userImage = self.profileImage.image
            }
        })
        
        //Auth display name is both first and last.,  Need to concatenate these two values before storing
        let displayName = "\(firstName.text!) \(lastName.text!)"
        
        if(fnChanged == true || lnChanged == true || emailChanged == true){
            Auth.auth().currentUser?.setValue(displayName, forKey: "displayName")
            Auth.auth().currentUser?.updateEmail(to: confirmEmail.text!, completion: { (error) in
                if(error != nil){
                    errorMessageAlert(title: "Error!", message: "Error saving email.", thisView: self)
                }
            })
            mainDelegate.displayName = displayName
        }
        
        //update CoreData
        activity.startAnimating()
        saveDataToCoreData(inDisplayName: displayName) { (result) in
            if(result){
                activity.stopAnimating()
                profileUpdatedAlert(title: "Profile Updated!", message: "Profile succesfully updated!", thisView: self)
                activity.stopAnimating()
            }else{
                activity.stopAnimating()
                errorMessageAlert(title: "Error!", message: "Error updating profile!", thisView: self)
                activity.stopAnimating()
            }
        }
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        let VC1 = self.storyboard?.instantiateViewController(withIdentifier: "Reset Password") as! ResetPasswordViewController
        VC1.inEmailAddress = email.text
        self.present(VC1, animated: true, completion: nil)
    }
    
    
    func setupProfileImage(){
        profileImage.image = inImage
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = false
        profileImage.isUserInteractionEnabled = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageTapped)))
        profileImage.addSubview(setupOverlayImage())
    }
    
    func setupOverlayImage()->UIImageView{
        if #available(iOS 13.0, *) {
            overlayImageView.image = UIImage(systemName: "camera")
            overlayImageView.contentMode = .scaleAspectFit
        } else {
            // Fallback on earlier versions
        }
        overlayImageView.alpha = 0.6
        overlayImageView.layer.cornerRadius =  overlayImageView.frame.size.width / 2
        overlayImageView.center = CGPoint(x: profileImage.frame.size.width  / 2,
        y: profileImage.frame.size.height / 2)
        let retImage = overlayImageView
        return retImage
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
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func profileImageTapped(){
        chooseImageFromPhoto(source: .photoLibrary)
    }
    
    @objc func cameraImageTapped(){
        chooseImageFromCamera(source: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImage.image = image
            imageChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func chooseImageFromPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func chooseImageFromCamera(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc func isValidEmail(object: UITextField) {
        let testStr = object.text!
        if(object.accessibilityIdentifier == "confirmEmail" && object.text?.count == 0){
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
    
    @objc func selectAllText(object: UITextField){
        object.becomeFirstResponder()
        object.selectAll(nil)
    }
    
    @objc func textFieldChanged(object: UITextField){
        switch object.accessibilityIdentifier {
        case "firstName":
            if(object.text == inFN){
                fnChanged = false
            }else{
                fnChanged = true
            }
            print(fnChanged)
        case "lastName":
            if(object.text == inLN){
                lnChanged = false
            }else{
                lnChanged = true
            }
            print(lnChanged)
        case "email":
            if(object.text == inEmail){
                emailChanged = false
            }else{
                emailChanged = true
            }
            print(emailChanged)
        case "confirmEmail":
            if(object.text!.count > 0 && object.text != email.text){
                saveButton.isEnabled = false
                errorMessageAlert(title: "Password Mismatch", message: "Passwords don't match.", thisView: self)
            }else{
                saveButton.isEnabled = true
                emailChanged = true
            }
            print(emailChanged)
        default:
            return
        }
    }
    
    func saveDataToCoreData(inDisplayName: String, completion: (Bool)->()){
        
        //Get reference to the Entity VOTD
        let context = DataController.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newValue = NSManagedObject(entity: entity!, insertInto: context)
        
        //Set data to the referenced entity attributes
        //newValue.setValue(mainDelegate.userImage.jpegData(compressionQuality: 1.0), forKey: "image")
        newValue.setValue(inDisplayName, forKey: "displayName")
        newValue.setValue(profileImage.image!.jpegData(compressionQuality: 1.0), forKey: "image")
        
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
        
}

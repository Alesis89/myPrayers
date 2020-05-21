//
//  AddPrayerViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/19/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class AddPrayerViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var prayForTxt: UITextField!
    @IBOutlet weak var prayerTxt: UITextView!
    @IBOutlet weak var addPrayerBtn: UIButton!
    var userID: String!
    
    //Reference to Firebase DB
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createToolbar()
        
        setupAddPrayerButton()
        
        //Get userId of logged in user
        userID = Auth.auth().currentUser?.uid
        
        //customize Textfield to add a border
        let myColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        prayerTxt.delegate = self
        prayerTxt.layer.borderColor = myColor.cgColor
        prayerTxt.layer.borderWidth = 1.0
        prayerTxt.layer.cornerRadius = 5.0
        prayerTxt.layer.masksToBounds = true
        prayerTxt.text = "Prayer?"
        prayerTxt.textColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        
        
        prayForTxt.addTarget(self, action: #selector(isValidPrayForLength(object:)), for: .editingChanged)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Prayer?"){
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Prayer?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func addPrayer(_ sender: Any) {
    
        let currentDateTime = getCurrentDateTime()
        
        //create Array of the data to add
        let prayerdata = ["createDateTime": "\(currentDateTime)", "prayFor": "\(prayForTxt.text!)", "prayer": "\(prayerTxt.text!)" ]
        
        //setup activity indicator
        let activity = UIActivityIndicatorView(style: .gray)
        
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        view.addSubview(activity)
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //Add data to firebase
        let prayerKey = ref.child("prayers/\(userID!)").childByAutoId().key!
        ref.child("prayers/\(userID!)").child(prayerKey).setValue(prayerdata){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                errorMessageAlert(title: "Error!", message: "\(error)", thisView: self)
                activity.stopAnimating()
            } else {
                prayerAddedAlert(title: "Prayer Added!", message: "Prayer succesfully added.", thisView: self)
                activity.stopAnimating()
            }
        }
    }
    
    func setupAddPrayerButton(){
        addPrayerBtn.layer.cornerRadius = 10
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexible = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexible,doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        prayerTxt.inputAccessoryView = toolbar
        prayForTxt.inputAccessoryView = toolbar
    }
    
    @objc func isValidPrayForLength(object: UITextField){
        
        if (object.text!.count > 20){
            object.deleteBackward()
        }
    }
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }
}

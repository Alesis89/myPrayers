//
//  VOTDViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/4/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import CoreData

class VOTDViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var verseText: UITextView!
    var storedCalDay = Int()
    var currentCalDay = Int()
    
    var shouldStartTimer = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCalDay = getCalendarDayForVOTD()
        
        //Check to see if stored image, verse, calendar day
        
        getDataFromCoreData { (result) in
            if(result){
                if(storedCalDay != currentCalDay){
                    //Get today's verse from API
                    getTodaysVerse(completion: { (result) in
                        if(result){
                            DispatchQueue.main.async {
                                self.saveData()
                                if(self.shouldStartTimer == true){
                                    self.image.isHidden = false
                                    //Show VOTD for 7 seconds, then go to login screen
                                    self.startTimer()
                                }
                            }
                        }
                    })
                }else{
                    if(self.shouldStartTimer == true){
                        image.isHidden = false
                        self.startTimer()
                    }
                }
            }else{
                getTodaysVerse { (result) in
                    if(result){
                        DispatchQueue.main.async {
                            self.saveData()
                            if(self.shouldStartTimer == true){
                                self.image.isHidden = false
                                self.startTimer()
                            }
                        }
                    }
                }
            }
        }
        
        //check to see if we are coming from them menu.  shouldStartTimer will be false if so.
        if(shouldStartTimer == false){
            self.image.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareVOTD))
            
            //This allows the view to start below the navigation bar
            edgesForExtendedLayout = []
            //Previous command makes the navigationbar translucent.  Have to reset it back to false.
            self.navigationController?.navigationBar.isTranslucent = false
        }
    }
    
    //Save Image, Verse, Calendar day to Core Data
    func saveData(){
        
        //Get reference to the Entity VOTD
        let context = DataController.shared.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "VOTD", in: context)
        let newValue = NSManagedObject(entity: entity!, insertInto: context)

        //Set data to the referenced entity attributes
        newValue.setValue(image.image?.jpegData(compressionQuality: 1.0), forKey: "image")
        newValue.setValue(calendarDay, forKey: "day")
        newValue.setValue(verseText.text, forKey: "verse")
        
        //save data into attributes
        do{
            try context.save()
        }catch{
        }
    }
    
    func getDataFromCoreData(completion: (Bool)->Void){
        
        //Check core data to see if we already have the VOTD image, verse, and calendar day for today's calendar day.
        //If so, we don't need to make another api call.
        
        let context = DataController.shared.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "VOTD")
        request.returnsObjectsAsFaults = false
        
        //Get data from coreData if exists
        do{
            let result = try context.fetch(request)
            
            if result.count > 0{
                for data in result as! [NSManagedObject]{
                    verseText.text = data.value(forKey: "verse") as? String
                    storedCalDay = data.value(forKey: "day") as! Int
                    if let temp = data.value(forKey: "image"){
                        image.image = UIImage(data: temp as! Data)
                        //temporarily hide the image until we know if we want to show the current one, or get one from API.
                        image.isHidden = true
                    }else{
                         verseText.isHidden = false
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
        
    func startTimer(){
        _ = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false, block: { timer in
            self.goToLogin()
        })
    }
    
    func goToLogin(){
        let window: UIWindow?
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "Login Controller") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        
        
//        let loginVC = self.storyboard!.instantiateViewController(withIdentifier: "Login Controller") as! LoginViewController
//        self.present(loginVC, animated: true, completion: nil)
    }
    
    func getTodaysVerse(completion: @escaping (Bool)->Void){
        
        //Get VOTD from YouVersion API.  Show image first, and text if no image available
        getVOTD(){result, data in
            
            if(result){
                let getURL = data["ImgURL"]
                let trimmedURL = getURL?.dropFirst(56)
                
                if let imageURL = URL(string: String(trimmedURL!)){
                    DispatchQueue.global(qos: .background).async {
                        if let imageData = try? Data(contentsOf: imageURL) {
                            DispatchQueue.main.async {
                                self.image.image = UIImage(data: imageData)
                                self.verseText.isHidden = true
                                self.verseText.text = data["VerseText"]
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.verseText.isHidden = false
                                self.verseText.text = data["VerseText"]
                            }
                        }
                        completion(true)
                        return
                    }
                }else{
                    //If no image returned, show the verse text instead
                    DispatchQueue.main.async {
                        self.verseText.isHidden = false
                        self.verseText.text = data["VerseText"]
                    }
                    completion(true)
                    return
                }
            }else{
                //cannot get api data
                DispatchQueue.main.async {
                    self.verseText.text = "Error getting verse of the day"
                }
                completion(false)
                return
            }
        }
    }
    
    @objc func shareVOTD(){
        
        //Because saving images to photo library causes the UIActivityViewController to close down to the root view controler (my login page)
        //this is a work around to allow saving to photo library that will close down the fakeViewController and take me back to my
        //ViewController.
        
        let fakeViewController = UIViewController()
        fakeViewController.modalPresentationStyle = .overCurrentContext
        let shareVOTD = UIActivityViewController(activityItems: [image.image!], applicationActivities: nil)
            shareVOTD.completionWithItemsHandler = {(activity: UIActivity.ActivityType?,success:Bool,items:[Any]?,error:Error?) in
                if(success){
                    if let presentingViewController = fakeViewController.presentingViewController {
                        presentingViewController.dismiss(animated: false, completion: nil)
                    } else {
                        fakeViewController.dismiss(animated: false, completion: nil)
                    }
                }else{
                    if let presentingViewController = fakeViewController.presentingViewController {
                        presentingViewController.dismiss(animated: false, completion: nil)
                    } else {
                        fakeViewController.dismiss(animated: false, completion: nil)
                    }
                }
            }
        self.present(fakeViewController, animated: true) { [weak fakeViewController] in
            fakeViewController?.present(shareVOTD, animated: true, completion: nil)
        }
    }
}

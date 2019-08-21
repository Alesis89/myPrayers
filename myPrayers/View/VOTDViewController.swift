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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
                                //Show VOTD for 7 seconds, then go to login screen
                                self.startTimer()
                            }
                            
                        }
                    })
                }else{
                    self.startTimer()
                }
            }else{
                getTodaysVerse { (result) in
                    if(result){
                        DispatchQueue.main.async {
                            self.saveData()
                            self.startTimer()
                        }
                    }
                }
            }
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
            print("Saved Data!")
        }catch{
            print("Failed to save data!")
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
            print("Failed to get data!")
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
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Login Controller") as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        
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
                print("no connection")
                //cannot get api data
                DispatchQueue.main.async {
                    self.verseText.text = "Error getting verse of the day"
                }
                completion(false)
                return
            }
        }
    }
}

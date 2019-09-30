//
//  PrayersTableViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 8/12/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PrayersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //set our slider menu varibale to the Menu object
    let sliderMenu = Menu()
    
    //set variable to our tableView so we can refresh on data updates
    @IBOutlet var prayerTableView: UITableView!
    
    //Setup Array to append firebase info
    var prayerData: [Prayer] = []
    let userId = Auth.auth().currentUser?.uid
    
    //Reference to Firebase DB
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("prayers/\(userId!)").observe(.childAdded) { (data) in
            let prayerData = data.value as? [String:Any]
            let prayerKey = data.key
            let createDateTime = prayerData?["createDateTime"] as? String
            let prayFor = prayerData?["prayFor"] as? String
            let prayer = prayerData?["prayer"] as? String
            
            let prayerToAdd = Prayer.init(prayerKey: prayerKey, createDateTime: createDateTime!, prayFor: prayFor!, prayer: prayer!, userID: self.userId!)
            self.prayerData.insert(prayerToAdd, at: 0)
            self.prayerTableView.reloadData()
        }
        
        ref.child("prayers/\(userId!)").observe(.childChanged) { (data) in
            
            let prayerData = data.value as? [String:Any]
            let prayerKey = data.key
            let prayFor = prayerData?["prayFor"] as? String
            let prayer = prayerData?["prayer"] as? String
            var itemIndex = 0
            
            for item in self.prayerData{
               
                if item.prayerKey == prayerKey{
                    self.prayerData[itemIndex].prayFor = prayFor!
                    self.prayerData[itemIndex].prayer = prayer!
                    itemIndex += 1
                }else{
                    itemIndex += 1
                }
            }
            
            self.prayerTableView.reloadData()
        }
        
        ref.child("prayers/\(userId!)").observe(.childRemoved) { (data) in
            let prayerKey = data.key
            
            for item in self.prayerData{
                if item.prayerKey == prayerKey{
                   self.prayerData.remove(at: 0)
                }
            }
            
           self.prayerTableView.reloadData()
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        sliderMenu.showMenu()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayerData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let VC1 = self.storyboard?.instantiateViewController(withIdentifier: "View Prayer") as! ViewPrayerViewController
        VC1.inPrayFor = self.prayerData[indexPath.row].prayFor
        VC1.inPrayer = self.prayerData[indexPath.row].prayer
        self.show(VC1, sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prayerCell") as! PrayerTableViewCell
        cell.lblPrayForText.text = prayerData[indexPath.row].prayFor
        cell.lblTime.text = formatCalDayForCell(inDate: prayerData[indexPath.row].createDateTime)
        cell.lblPrayer.text = prayerData[indexPath.row].prayer
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let alertController = UIAlertController(title: "Delete Prayer", message: "Are you sure you want to delete this prayer?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Yes", style: .default){ (UIAlertAction) in
                let delKey = self.prayerData[indexPath.row].prayerKey
                self.ref.child("prayers/\(self.userId!)").child("\(delKey)").removeValue()
                self.prayerData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let cancel = UIAlertAction(title: "No", style: .cancel){ (UIAlertAction) in
                //Nothing to do here.
            }
            cancel.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(ok)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
        let modify = UITableViewRowAction(style: .normal, title: "Modify") { action, index in
            let modKey = self.prayerData[indexPath.row].prayerKey
            
            let VC1 = self.storyboard?.instantiateViewController(withIdentifier: "Modify Prayer") as! ModifyPrayerViewController
            VC1.inPrayerKey = modKey
            VC1.inCreateDateTime = self.prayerData[indexPath.row].createDateTime
            VC1.inPrayFor = self.prayerData[indexPath.row].prayFor
            VC1.inPrayer = self.prayerData[indexPath.row].prayer
            self.show(VC1, sender: self)
           
        }
        modify.backgroundColor = UIColor(red: 194.0/255.0, green: 194.0/255.0, blue: 223.0/255.0, alpha: 1.0)
        
        return [delete, modify]
    }
    
}

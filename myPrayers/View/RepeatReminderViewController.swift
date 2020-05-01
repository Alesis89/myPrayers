//
//  RepeatReminderViewController.swift
//  myPrayers
//
//  Created by Bill Clark on 4/30/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import UIKit

protocol SelectedRepeatDelegate {
    func didSelectRepeat(repeatOption: String?)
}

class RepeatReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let repeatOptions = ["Never","Daily","Weekly","Monthly","Yearly"]
    var selectedRepeatDelegate: SelectedRepeatDelegate!
    @IBOutlet weak var tableView: UITableView!
    var inRepeatSetting = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set table attributes
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.init(red: 194/255, green: 194/255, blue: 223/255, alpha: 1.0)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatOptions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
        cell.tintColor = UIColor.purple
        
        //remove checkmark from previous items
        for i in 0...4{
            if(i != indexPath.row){
                guard let cellDeselect = tableView.cellForRow(at: IndexPath(row: i, section: 0)) else { return }
                cellDeselect.accessoryType = .none
            }
        }
        selectedRepeatDelegate.didSelectRepeat(repeatOption: (cell.textLabel?.text))
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Repeat Cell", for: indexPath)
        cell.textLabel?.text = repeatOptions[indexPath.row]
        cell.tintColor = UIColor.purple
        
        if (cell.textLabel!.text! == inRepeatSetting){
            cell.accessoryType = .checkmark
        }
        return cell
    }
}

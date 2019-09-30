//
//  Menu.swift
//  myPrayers
//
//  Created by Bill Clark on 8/12/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class Menu: NSObject, UITableViewDelegate, UITableViewDataSource{

    //Setup Variables
    let exitButton = UIButton()
    let menuView = UIView()
    let profileView = UIView()
    var votdSetting = UISwitch()
    var votdLabel = UILabel()
    var profileUserName = UILabel()
    var profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
    var settingsImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    let settingsButton = UIButton()
    let blackBackgroundView = UIView()
    let versionLabel = UILabel()
    var topVC = UIViewController()
    let mainDelegate = UIApplication.shared.delegate as! AppDelegate
    var tableView = UITableView()

    func showMenu(){
        
        if let window = UIApplication.shared.keyWindow{
            let height = window.frame.height
            let width: CGFloat = 250
    
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = .white
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            
            //Call function to setup a black grounds that our menu will show on top of
            setupBlackBackground(window: window)
            
            //Call function to create menu view that will hold a signout button
            setupMenuView(window: window)
           
            //Create profile view that will sit inside the menu view at the top to show profile details
            setupProfileView(window: window)
            
            //Setup objects that will sit in the profile view
            setupProfileImage()
            setupProfileName()
            setupSettingsButton()
            profileView.addSubview(profileImageView)
            profileView.addSubview(profileUserName)
            profileView.addSubview(settingsButton)
            
            setProfileImageConstraints()
            setProfileNameConstraints()
            setSettingsButtonConstraints()
            
            //add profile view to menuView before adding to main window
            menuView.addSubview(profileView)
            
           //Setup objects that will sit in the menu view
            setupVotdLabel()
            setupVOTDSwitch()
            setVOTDSwitch()
            setupVersionLabel()
            setupExitButton()
            
            //menuView.addSubview(self.votdSetting)
            //menuView.addSubview(votdLabel)
            menuView.addSubview(tableView)
            menuView.addSubview(versionLabel)
            menuView.addSubview(self.exitButton)
           
            //setVOTDSwitchConstraints()
            //setVotdConstraints()
            setTableConstraints()
            setVersionConstraints()
            setExitButtonConstraints()
            
            //Add our blackview and menuView to main window
            window.addSubview(blackBackgroundView)
            window.addSubview(menuView)
            
            //Show views using slider animation effect
            UIView.animate(withDuration: 0.5) {
                self.blackBackgroundView.alpha = 1
                self.menuView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        }
    }
    
    func setupBlackBackground(window: UIWindow){
        //When menu opens, darken the background vc with this blackview
        blackBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackBackgroundView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleDismiss)))
        blackBackgroundView.frame = window.frame
        blackBackgroundView.alpha = 0
    }
    
    func setupMenuView(window: UIWindow){
        menuView.frame = CGRect(x: 0, y: 0, width: -250, height: window.frame.height)
        menuView.backgroundColor = UIColor.white
    }
    
    func setupProfileView(window: UIWindow){
        profileView.frame = CGRect(x: 0, y: 0, width: 250, height: window.frame.height/4)
        profileView.backgroundColor = UIColor.white
        profileView.layer.shadowColor = UIColor.black.cgColor
        profileView.layer.shadowOpacity = 1
        profileView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        profileView.layer.shadowRadius = 0
        profileView.layer.masksToBounds = false
    }
    func setupSettingsButton(){
        settingsImageView.image = UIImage(named: "settings")
        settingsButton.setImage(settingsImageView.image, for: .normal)
        settingsButton.setTitleColor(UIColor.red, for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsButtonAction(_:)), for: .touchUpInside)
    }
    
    func setSettingsButtonConstraints(){
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -5).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -5).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupProfileImage(){
        profileImageView.image = mainDelegate.userImage
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = false
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    func setProfileImageConstraints(){
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.topAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 110).isActive = true
    }
    
    func setupProfileName(){
        profileUserName.text = mainDelegate.displayName
        profileUserName.font = UIFont(name: "Avenir Next", size: 14)
    }
    
    func setProfileNameConstraints(){
        profileUserName.translatesAutoresizingMaskIntoConstraints = false
        profileUserName.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        profileUserName.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
    }

    func setVersionConstraints(){
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.centerXAnchor.constraint(equalTo: menuView.centerXAnchor).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: menuView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    func setupVersionLabel(){
        versionLabel.text = getVersionWithBuildNumber()
        versionLabel.font = UIFont(name: "Avenir Next", size: 12)
    }

    func setupVotdLabel(){
        votdLabel.text = "Verse of the Day:"
        votdLabel.font = UIFont(name: "Avenir Next", size: 14)
    }
    
    func setVotdConstraints(){
        votdLabel.translatesAutoresizingMaskIntoConstraints = false
        votdLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 10).isActive = true
        votdLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        votdLabel.topAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.bottomAnchor, constant: 30).isActive = true
    }
    
    func setTableConstraints(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 30).isActive = true
        tableView.bottomAnchor.constraint(equalTo: exitButton.topAnchor, constant: -30).isActive = true
        //tableView.heightAnchor.constraint(equalToConstant:50).isActive = true
        tableView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: 0).isActive = true
    }
    
    func setupVOTDSwitch(){
        votdSetting = UISwitch(frame:CGRect(x: 150, y: 150, width: 0, height: 0))
        votdSetting.addTarget(self, action: #selector(VOTDSwitchTapped), for: .touchUpInside)
    }
    
    func setVOTDSwitchConstraints(){
        votdSetting.translatesAutoresizingMaskIntoConstraints = false
        votdSetting.heightAnchor.constraint(equalToConstant: 50).isActive = true
        votdSetting.leadingAnchor.constraint(equalTo: votdLabel.trailingAnchor, constant: 20).isActive = true
        votdSetting.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -20).isActive = true
        votdSetting.topAnchor.constraint(equalTo: profileView.safeAreaLayoutGuide.bottomAnchor, constant: 30).isActive = true
    }
    
    func setupExitButton(){
        exitButton.backgroundColor = UIColor.white
        exitButton.setTitle("Sign Out", for: UIControl.State.normal)
        exitButton.setTitleColor(UIColor.red, for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        exitButton.layer.cornerRadius = 10.0
        exitButton.layer.borderWidth = 1.0
        exitButton.layer.borderColor = UIColor.red.cgColor
        exitButton.addTarget(self, action: #selector(self.exitButtonAction(_:)), for: .touchUpInside)
    }
    
    func setExitButtonConstraints(){
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        exitButton.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 20).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -20).isActive = true
        exitButton.bottomAnchor.constraint(equalTo: menuView.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
    }
    
    @objc func setVOTDSwitch(){
        let setSwitchTo = UserDefaults.standard.value(forKey: "VOTD-ON") as? Bool
        votdSetting.setOn(setSwitchTo!, animated: false)
    }
    
    @objc func VOTDSwitchTapped(){
        //Set User Detault for switch
        if (votdSetting.isOn){
            UserDefaults.standard.set(true, forKey: "VOTD-ON")
            setVOTDSwitch()
        }else{
            UserDefaults.standard.set(false, forKey: "VOTD-ON")
            setVOTDSwitch()
        }
    }
    
    @objc func settingsButtonAction(_ sender:UIButton!){
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        let SC1 = topVC?.storyboard?.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        
        //set data in SC1 form
        SC1.inImage = profileImageView.image!
        if let splitDisplayName = profileUserName.text?.split(separator: " "){
            SC1.inFN = String(splitDisplayName[0])
            SC1.inLN = String(splitDisplayName[1])
            SC1.inEmail = (Auth.auth().currentUser?.email)!
        }
        topVC?.show(SC1, sender: topVC)
        blackBackgroundView.alpha = 0
        let height = UIApplication.shared.keyWindow?.frame.height
        menuView.frame = CGRect.init(x: 0, y: 0, width: -250, height: height!)
    }
    
    @objc func exitButtonAction(_ sender:UIButton!){
        handleDismiss(logout: true)
    }
    
    @objc func handleDismiss(logout: Bool){
        
        if logout{
            
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            
            //Confirm user wants to logout
            let alertController = UIAlertController(title: "Confirm Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancel.setValue(UIColor.red, forKey: "titleTextColor")
            let confirm = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                
                UIView.animate(withDuration: 0.1) {
                    let height = UIApplication.shared.keyWindow?.frame.height
                    self.blackBackgroundView.alpha = 0
                    self.menuView.frame = CGRect.init(x: 0, y: 0, width: -250, height: height!)
                }
//                do{
//                    try Auth.auth().signOut()
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "Login Controller")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
//                }catch{
//                    print(error)
//                }
                
            }
            
            alertController.addAction(cancel)
            alertController.addAction(confirm)
            topVC!.present(alertController, animated: true, completion: nil)
            
        }else{
            UIView.animate(withDuration: 0.5) {
                let height = UIApplication.shared.keyWindow?.frame.height
                self.blackBackgroundView.alpha = 0
                self.menuView.frame = CGRect.init(x: 0, y: 0, width: -250, height: height!)
            }
        }
    }
    
    func getVersionWithBuildNumber()->String{
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary![AppVersionBuildConstants.versionNumber] as! String
        let build = dictionary![AppVersionBuildConstants.buildNumber] as! String
        
        return "v\(version) (\(build))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        }else if (section == 1){
            return 1
        }else if (section == 2){
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //should change StaticCell to the static cell class you want to use.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        if indexPath.section == 0{
            cell.textLabel?.text = "Coming Soon..."
            return cell
        }else if indexPath.section == 1{
            cell.textLabel?.text = votdLabel.text
            cell.accessoryView = votdSetting
            return cell
        }else if indexPath.section == 2{
            if(indexPath.row == 0){
                cell.textLabel?.text = "Face ID:  Coming Soon..."
                return cell
            }else if (indexPath.row == 1){
                cell.textLabel?.text = "Reset Password:  Coming Soon..."
                return cell
            }else{
                return cell
            }
            
        }else{
            return cell
        }
        //cell.textLabel?.text = "Test\(indexPath.row)"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont(name: "Avenir Next-Bold", size: 14.0)
        
        if(section == 0){
            label.text = "Notifications"
            return label
        }else if (section == 1){
            label.text = "Verse of the Day"
            return label
        }else if (section == 2){
            label.text = "Profile Security"
            return label
        }else{
            return label
        }
    }
}

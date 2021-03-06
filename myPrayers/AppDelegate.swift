//
//  AppDelegate.swift
//  myPrayers
//
//  Created by Bill Clark on 8/4/19.
//  Copyright © 2019 Bill Clark. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var displayName: String!
    var userImage: UIImage!
    let notificationCenter = UNUserNotificationCenter.current()
    var userStatus = LoggedInStatus.notSet
    
    //Using enum to set if the user is logged in or out.  notSet represents the user first launching the app.  Logged out is for when the user logs out of the app and comes back to this login screen.  What we will be preventing is the biometric login launching again if the user just logged out.  We only want it to auto-run if the user is first launching the app.
    enum LoggedInStatus {
        case loggedIn
        case loggedOut
        case notSet
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        
        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.purple], for: .normal)
        UINavigationBar.appearance().tintColor = .purple
        
        //Singleton DataController for Core Data
        DataController.shared.load()
        
        FirebaseApp.configure()
        
        
        //check to see if our VOTD has been turned off by the user.  If so, go straight to login screen
        
        _ = checkVOTDAtStartup(completion: { (result) in
            //check to see if VOTD is turned on.  If so, show the VOTD view controller first.
            if (result){
                let homePage: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "VOTD") as! VOTDViewController
                 self.window?.rootViewController = homePage
                window?.makeKeyAndVisible()

            }else{
                let homePage: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "Login Controller") as! LoginViewController
                 self.window?.rootViewController = homePage
                window?.makeKeyAndVisible()
            }
        })
        return true
    }
    
    func checkVOTDAtStartup(completion: (Bool)->Void){
        //This function will check to see if the user has selected to turn off the VOTD at startup
        //This will be a User Defaults setting
        
        //var showVOTD = false
        
        if let votdSet = UserDefaults.standard.value(forKey: "VOTD-ON") as? Bool{
            if(votdSet){
                //showVOTD = true
                completion(true)
            }else{
                //showVOTD = false
                completion(false)
            }
        }else{
            //First time app launch.  Set VOTD to true and show VOTD ViewController
            UserDefaults.standard.set(true, forKey: "VOTD-ON")
            //showVOTD = true
            completion(true)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        
        //log the user out
        do{
            try Auth.auth().signOut()
        }catch{
        }
         
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "myPrayers")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


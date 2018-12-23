//
//  StationViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class StationViewController: UIViewController {
    
    let username = "ldimuro"
    let stationPin = "OVHM"
    var userArray = [String]()
    var arrayOfUsers = [[String : Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "D S S O"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let userDict = ["Name": username]
        let ref = Database.database().reference().child("Stations").child(stationPin).child("Users")
        
        ref.child(username).setValue(userDict) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            } else {
                print("User added successfully")
            }
        }

//        getStationUsers()
//
//        //DELAYS FOR A SECOND TO GIVE TIME TO COMMUNICATE INFORMATION WITH SERVER
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // in a second...
//            for each in self.userArray {
//                print(each)
//            }
//        }
//
//        for each in userArray {
//            let userDict = ["Name": each]
//
//            arrayOfUsers.append(userDict)
//        }
//
//        let ref = Database.database().reference().child("Stations").child(stationPin).child("Users")
//
//        ref.setValue(arrayOfUsers)

//        ref.updateChildValues(["Users": userArray])

    }
    
    @IBAction func exitStationPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Leave Station option
        optionMenu.addAction(UIAlertAction(title: "Leave this Station", style: .destructive, handler:{ (UIAlertAction)in
            print("Left Station")
            self.dismiss(animated: true, completion: nil)
        }))
        
        //Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    func getStationUsers() {
        let userRef = Database.database().reference().child("Stations").child(stationPin).child("Users")
        
        //if USER != OWNER
            userArray.append(username)
        
        userRef.observe(.value) { (snapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                
                self.userArray.append(snapKey.value as! String)
                
            }
        }
    }
    
    
}

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

    }
    
    @IBAction func exitStationPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Leave Station option
        optionMenu.addAction(UIAlertAction(title: "Leave this Station", style: .destructive, handler:{ (UIAlertAction)in
            print("Left Station")
            
            let ref = Database.database().reference().child("Stations").child(self.stationPin).child("Users")
            
            ref.child(self.username).removeValue { (error, reference)  in
                if error != nil {
                    print("error \(error!)")
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        //Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
}

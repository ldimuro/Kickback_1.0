//
//  UsersViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 1/4/19.
//  Copyright © 2019 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userTableView: UITableView!
    var userArray = [[String:String]]()
    let hud = JGProgressHUD(style: .extraLight)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userTableView.delegate = self
        userTableView.dataSource = self
        
        hud.show(in: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStationUsers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        // Checks to see if it should mark the user's name as "owner" if they own the station
//        if indexPath.row == 0 && (UserDefaults.standard.string(forKey: "isOwner") != nil) {
//            cell.textLabel?.text = "\(userArray[indexPath.row]["Symbol"]!)\t\(userArray[indexPath.row]["User"]!)\t\t\t⭐️"
//        }
//        else {
            cell.textLabel?.text = "\(userArray[indexPath.row]["Symbol"]!)\t\(userArray[indexPath.row]["User"]!)"
//        }
        
//        cell.textLabel?.text = "\(userArray[indexPath.row]["Symbol"]!)\t\(userArray[indexPath.row]["User"]!)"
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func getStationUsers() {
        
//        let stationOwner = ["User": "\(UserData.username!)",
//            "Symbol": "\(UserData.symbol!)"]
//        userArray.append(stationOwner)
//        userTableView.reloadData()
//        hud.dismiss()
        
        let userRef = Database.database().reference().child("Stations").child(UserData.stationPin!).child("Users")
        
        userRef.observe(.childAdded) { (snapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let value = snapKey.value as! String
                let user = snapshot.key
                
                let userDict = ["User": user,
                                "Symbol": value]
                
                self.userArray.append(userDict)
                
                self.hud.dismiss()
                self.userTableView.reloadData()
                
            }
        }
    }
    
    

}

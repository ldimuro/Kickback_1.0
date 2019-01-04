//
//  UsersViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 1/4/19.
//  Copyright © 2019 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userTableView: UITableView!
    var userArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userTableView.delegate = self
        userTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStationUsers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = userTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        cell.textLabel?.text = userArray[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func getStationUsers() {
        
        let userRef = Database.database().reference().child("Stations").child(UserData.stationPin!).child("Users")
        
        userRef.observe(.childAdded) { (snapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let value = snapKey.value as! String
                
                print(value)
                
                self.userArray.append(value)
                
                self.userTableView.reloadData()
                
            }
        }
    }
    
    

}

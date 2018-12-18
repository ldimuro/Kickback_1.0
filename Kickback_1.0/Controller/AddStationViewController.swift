//
//  AddStationViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class AddStationViewController: UIViewController {
    
    @IBOutlet weak var pinLabel: UILabel!
    var pin: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pin = randomPin()
        
        pinLabel.text = pin
    }
    
    @IBAction func createButton(_ sender: Any) {
        
        saveStation()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Generates a random PIN that will be used to identify the station to other users
    func randomPin() -> String {
        
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        var randomPin = ""
        
        //Chooses 4 random letters
        for _ in 1...4 {
            let randomInt = Int.random(in: 0...23)
            
            randomPin = randomPin + alphabet[randomInt]
        }
        
        return randomPin
        
    }
    
    //Save station to Firebase
    func saveStation() {
        
        let addStation = Database.database().reference().child("Stations")
        let timestamp = "\(Date())"
        
        let songDict = ["Name": "Say It Ain't So",
                        "Artist": "Weezer",
                        "ID": "Jdjs9Djs",
                        "User": "Lou"] as [String : Any]
        
        let playlistDict = ["Name": "Lou's Playlist",
                            "Songs": [songDict, songDict, songDict, songDict],
                            "ID": "aDfs45gsD",
                            "Owner": "Lou"] as [String : Any]
        
        let postDictionary = ["Owner": "Lou",
                              "Users": ["Chantal", "Nick", "Caden", "Grant"],
                              "Playlists": [playlistDict, playlistDict, playlistDict, playlistDict],
                              "Queue": [songDict, songDict, songDict, songDict],
                              "Timestamp": timestamp] as [String : Any]
        
        addStation.child(pin!).setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Station saved successfully")
            }
        }
    }
    
    

}

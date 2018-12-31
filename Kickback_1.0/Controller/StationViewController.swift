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
import Kingfisher
import LoadingPlaceholderView

class StationViewController: UIViewController, UIApplicationDelegate {
    
    // MARK: VARIABLES
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var blurredAlbumArt: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    let username = "testUser"
    let stationPin = UserDefaults.standard.string(forKey: "station")
    let isOwner = UserDefaults.standard.bool(forKey: "isOwner")
    var userArray = [String]()
    var arrayOfUsers = [[String : Any]]()
    var accessToken = ""
    var songName = ""
    var songCode = ""
    var artistName = ""
    var albumArtURL = ""
    let loadingPlaceholderView = LoadingPlaceholderView()

    //MARK: VIEW DID LOAD/APPEAR
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = stationPin
        
        loadingPlaceholderView.gradientColor = .white
        loadingPlaceholderView.backgroundColor = .white
        loadingPlaceholderView.cover(view, animated: true)
//        loadingPlaceholderView.cover(albumArt, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // If user is not the owner, just adds user to the Station
        if !isOwner {
            let userDict = ["Name": username]
            let ref = Database.database().reference().child("Stations").child(stationPin!).child("Users")
            
            ref.child(username).setValue(userDict) {
                (error, reference) in
                
                if(error != nil) {
                    print(error!)
                } else {
                    print("User added successfully")
                }
            }
        }
        else {
            AppDelegate().initiateSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                
                self.loadingPlaceholderView.uncover(animated: true)
                
                self.songName = NowPlayingData.songName
                self.songCode = NowPlayingData.songCode
                self.artistName = NowPlayingData.artistName
                self.albumArtURL = NowPlayingData.albumCoverURL
                
                self.songNameLabel.text = self.songName
                self.artistLabel.text = self.artistName
                
                let url = URL(string: self.albumArtURL)
                self.albumArt.kf.setImage(with: url)
                self.blurredAlbumArt.kf.setImage(with: url)
                
                
                
            })
        }
    }
    
    //MARK: BUTTONS
    
    @IBAction func exitStationPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If user is owner of the station and leaves, the entire station is removed
        if isOwner {
            optionMenu.addAction(UIAlertAction(title: "Leave this Station", style: .destructive, handler:{ (UIAlertAction)in
                print("Left Station, access token = \(self.accessToken)")
                
//                self.appRemote.playerAPI?.pause(nil)    // Pause Spotify
//                self.appRemote.disconnect()             // Disconnect from Spotify
                
                let ref = Database.database().reference().child("Stations").child(self.stationPin!)
                
                ref.removeValue { (error, reference)  in
                    if error != nil {
                        print("error \(error!)")
                    }
                }
                
                UserDefaults.standard.set(false, forKey: "isOwner")
                UserDefaults.standard.set("none", forKey: "station")
                
                self.dismiss(animated: true, completion: nil)
            }))
        }
        //If user is not the owner and leaves, only they will be removed from the station
        else {
            optionMenu.addAction(UIAlertAction(title: "Leave this Station", style: .destructive, handler:{ (UIAlertAction)in
                print("Left Station")
                
                let ref = Database.database().reference().child("Stations").child(self.stationPin!).child("Users")
                
                ref.child(self.username).removeValue { (error, reference)  in
                    if error != nil {
                        print("error \(error!)")
                    }
                }
                
                UserDefaults.standard.set("none", forKey: "station")
                
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        //Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
}

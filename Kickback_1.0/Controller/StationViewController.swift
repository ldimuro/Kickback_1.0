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
import JGProgressHUD

class StationViewController: UIViewController, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: VARIABLES
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nowPlayingView: UIView!
    @IBOutlet weak var queueTableView: UITableView!
    @IBOutlet weak var cellSymbol: UILabel!
    
    let username = "hello"
    let stationPin = UserDefaults.standard.string(forKey: "station")
    let isOwner = UserDefaults.standard.bool(forKey: "isOwner")
    var userArray = [String]()
    var arrayOfUsers = [[String : Any]]()
    var accessToken = ""
    var songName = ""
    var songCode = ""
    var artistName = ""
    var albumArtURL = ""
    var user = ""
    var symbol = ""
    let loadingPlaceholderView = LoadingPlaceholderView()
    let hud = JGProgressHUD(style: .light)

    //MARK: VIEW DID LOAD/APPEAR
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = stationPin
        
        queueTableView.delegate = self
        queueTableView.dataSource = self
        
        hud.textLabel.text = "Loading Station"
        hud.show(in: self.view)
        
//        loadingPlaceholderView.gradientColor = .white
//        loadingPlaceholderView.backgroundColor = .white
//        loadingPlaceholderView.cover(nowPlayingView, animated: true)
//        loadingPlaceholderView.cover(albumArt, animated: true)
        
        // Randomly assigns an emoji to each person who joins the station
        let emojis = ["💀", "👽", "😈", "👾", "🤖", "🤡", "🐱", "🐶", "🐭",
                      "🐼", "🐷", "🐸", "🐵", "🌞", "🌝", "🌚", "🌎", "❄️",
                      "🍪", "⚽️", "🏀", "🏈", "⚾️", "🎱", "🎲", "💿", "🔆",
                      "🌐", "🌀", "🔵", "🔴", "🕒", "💎"]
        
        let randomInt = Int.random(in: 0..<emojis.count)
        UserData.symbol = emojis[randomInt]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        updateNowPlaying()
        
        // If user is not the owner, just adds user to the Station
        if !isOwner {
            let userDict = ["Symbol": UserData.symbol]
            let ref = Database.database().reference().child("Stations").child(stationPin!).child("Users")
            
            ref.child(username).setValue(userDict) {
                (error, reference) in
                
                if(error != nil) {
                    print(error!)
                } else {
                    print("User added successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        
//                        self.loadingPlaceholderView.uncover(animated: true)
                        self.hud.dismiss()
                        
                        self.songName = NowPlayingData.songName
                        self.songCode = NowPlayingData.songCode
                        self.artistName = NowPlayingData.artistName
                        self.albumArtURL = NowPlayingData.albumCoverURL
                        
                        self.songNameLabel?.text = self.songName
                        self.artistLabel?.text = self.artistName
                        
                        let url = URL(string: self.albumArtURL)
                        self.albumArt.kf.setImage(with: url)
                        
                        self.queueTableView.reloadData()
                    })
                }
            }
        }
        else {
//            AppDelegate().initiateSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                
//                self.loadingPlaceholderView.uncover(animated: true)
                self.hud.dismiss()
                
//                self.getNowPlaying()
                
//                self.songNameLabel?.text = self.songName
//                self.artistLabel?.text = self.artistName
//
//                let url = URL(string: self.albumArtURL)
//                self.albumArt.kf.setImage(with: url)
                
                self.queueTableView.reloadData()
            })
        }
    }
    
    func updateNowPlaying() {
        
        print("UPDATE NOW PLAYING")
        
        

        self.queueTableView.reloadData()
        
        let userRef = Database.database().reference().child("Stations").child(UserData.stationPin!).child("Now Playing")
        
        userRef.observe(.childChanged) { (snapshot) in
            print("SONG UPDATED")
            print("Update song? \(NowPlayingData.songChanged)")
            
            if NowPlayingData.songChanged {
                
                self.songName = NowPlayingData.songName
                self.songCode = NowPlayingData.songCode
                self.artistName = NowPlayingData.artistName
                self.albumArtURL = NowPlayingData.albumCoverURL
                self.user = NowPlayingData.user
                self.symbol = NowPlayingData.symbol
                
                self.songNameLabel?.text = self.songName
                self.artistLabel?.text = self.artistName
                self.symbolLabel?.text = UserData.symbol
                
                let url = URL(string: self.albumArtURL)
                self.albumArt.kf.setImage(with: url)
                
                print("FIRST IN LINE:")
                print("********************")
                print("\(self.songName) - \(self.artistName)")
                print("********************")
                
                self.queueTableView.reloadData()
                
//            NowPlayingData.songChanged = false
            }
            else {
//                NowPlayingData.songChanged = !NowPlayingData.songChanged

            }
            
            
            
        }
    }
    
    func getNowPlaying() {
        self.songName = NowPlayingData.songName
        self.songCode = NowPlayingData.songCode
        self.artistName = NowPlayingData.artistName
        self.albumArtURL = NowPlayingData.albumCoverURL
        
        let nowPlayingRef = Database.database().reference().child("Stations").child(UserData.stationPin!).child("Now Playing")
        
        //The final dictionary of station
        let nowPlayingDict = ["Name": NowPlayingData.songName,
                              "ID": NowPlayingData.songCode,
                              "Artist": NowPlayingData.artistName,
                              "Album Art": NowPlayingData.albumCoverURL]
        
        nowPlayingRef.setValue(nowPlayingDict) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Now Playing saved successfully")
//                self.observeNowPlaying()
            }
        }
    }
    
    //MARK: TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = queueTableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
        
        cell.textLabel?.text = UserData.queue[indexPath.row].name
        cell.detailTextLabel?.text = UserData.queue[indexPath.row].artist
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: BUTTONS
    
    @IBAction func exitStationPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If user is owner of the station and leaves, the entire station is removed
        if isOwner {
            optionMenu.addAction(UIAlertAction(title: "Leave this Station", style: .destructive, handler:{ (UIAlertAction)in
                
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
                UserData.symbol = ""
                
//                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "exitStation", sender: nil)
            }))
        }
        // If user is not the owner and leaves, only they will be removed from the station
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
                UserData.symbol = ""
                
                self.dismiss(animated: true, completion: nil)
//                self.performSegue(withIdentifier: "exitStation", sender: nil)
            }))
        }
        
        //Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
}

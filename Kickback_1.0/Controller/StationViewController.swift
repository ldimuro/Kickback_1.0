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

class StationViewController: UIViewController, UIApplicationDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: VARIABLES
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nowPlayingView: UIView!
    @IBOutlet weak var queueTableView: UITableView!
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
    let loadingPlaceholderView = LoadingPlaceholderView()

    //MARK: VIEW DID LOAD/APPEAR
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = stationPin
        
        queueTableView.delegate = self
        queueTableView.dataSource = self
        
        loadingPlaceholderView.gradientColor = .white
        loadingPlaceholderView.backgroundColor = .white
        loadingPlaceholderView.cover(nowPlayingView, animated: true)
//        loadingPlaceholderView.cover(albumArt, animated: true)
        
        // Randomly assigns an emoji to each person who joins the station
        let emojis = ["👻", "💀", "☠️", "👽", "😈", "👾", "🤖", "🤡", "💩", "🐱",
                      "👁", "🧠", "👑", "🐶", "🐭", "🐼", "🐷", "🐸", "🐵", "🐴",
                      "🦄", "🐝", "🦑", "🐍", "🐬", "🐳", "🦃", "🐲", "🍄", "🌞",
                      "🌝", "🌚", "🌎", "⭐️", "🔥", "❄️", "🍎", "🍕", "🍔", "🍪",
                      "🍺", "⚽️", "🏀", "🏈", "⚾️", "🎱", "🎸", "🎬", "🎹", "🎲",
                      "🎧", "🚀", "🗿", "💿", "⏳", "💡", "💸", "💰", "🔮", "🎉",
                      "❤️", "☯️", "✴️", "💯", "🔆", "🔱", "⚜️", "✅", "🌐", "🌀",
                      "🔵", "🔴", "🕒", "♠️", "♣️", "♦️", "🔔", "🏴‍☠️", "🇺🇸", "💎"]
        
        let randomInt = Int.random(in: 0..<emojis.count)
        UserData.symbol = emojis[randomInt]
        symbolLabel.text = UserData.symbol
        
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
//            AppDelegate().initiateSession()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                
                self.loadingPlaceholderView.uncover(animated: true)
                
                self.getNowPlaying()
                
                self.songNameLabel?.text = self.songName
                self.artistLabel?.text = self.artistName
                
                let url = URL(string: self.albumArtURL)
                self.albumArt.kf.setImage(with: url)
                
                self.queueTableView.reloadData()
            })
        }
    }
    
    func updateNowPlaying(name: String, artist: String, id: String, art: String) {
        
        print("SONG UPDATED")
        // Update "Now Playing" every time a song ends and a new one begins
        let userRef = Database.database().reference().child("Stations").child(UserData.stationPin!)
        let post = ["Name": name,
                    "Artist": artist,
                    "ID": id,
                    "Album Art": art]
        
        let childUpdates = ["/Now Playing": post]
        userRef.updateChildValues(childUpdates)
        
//        loadingPlaceholderView.cover(nowPlayingView, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            print("**********")
            print("\(name) - \(artist) - \(id)")
            print("**********")
            
            self.songNameLabel.text = name
//            self.artistLabel!.text = artist
            
//            self.songName = NowPlayingData.songName
//            self.songCode = NowPlayingData.songCode
//            self.artistName = NowPlayingData.artistName
//            self.albumArtURL = NowPlayingData.albumCoverURL
            
//            self.loadingPlaceholderView.uncover(animated: true)
            
//            self.artistLabel.text = self.artistName
//
//            let url = URL(string: art)
//            self.albumArt.kf.setImage(with: url)
//            self.blurredAlbumArt.kf.setImage(with: url)
        })
        
        
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
                UserData.symbol = ""
                
                self.dismiss(animated: true, completion: nil)
            }))
        }
        
        //Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
}

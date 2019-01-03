//
//  AddStationViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import LoadingPlaceholderView

class AddStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var playlistTable: UITableView!
    
    var pin: String?
    var loadingPlaceholderView = LoadingPlaceholderView()
    let data = ["Lou's Playlist", "for you", "Wine Night", "Discover Weekly", "Sleep", "Mindmelt"]
    let genre = ["Indie", "Pop", "Indietronica", "Indie Rock", "Chill", "Psychedelic"]
    var playlistArray = [AddPlaylist]()
    var selectedPlaylists = [String]()
    var defaultOffset = 0
    var defaultLimit = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getPlaylists()
        
        playlistTable.delegate = self
        playlistTable.dataSource = self
//        playlistTable.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let formattedPin = randomPin()
        pin = formattedPin.replacingOccurrences(of: " ", with: "") // get rid of the spaces in-between each character
        pinLabel.text = formattedPin
        
        AppDelegate().initiateSession() // Start playing Spotify music
        
        // PAUSE FOR 4 SECONDS TO ALLOW TIME FOR COMMUNICATION WITH FIREBASE
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            repeat {
//                print("USER PLAYLISTS: \(UserData.playlists.count)")
                self.playlistTable.reloadData()
            } while UserData.accessToken == nil
            
            self.getAllSongs(offset: self.defaultOffset)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTable.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        cell.textLabel?.text = UserData.playlists[indexPath.row].name
        cell.detailTextLabel?.text = UserData.playlists[indexPath.row].owner
        
//        cell.textLabel?.text = playlistArray[indexPath.row].name
//        cell.detailTextLabel?.text = playlistArray[indexPath.row].genre
        
        //Check to see if a playlist has been selected
        if UserData.playlists[indexPath.row].added == true {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.playlists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UserData.playlists[indexPath.row].added = !UserData.playlists[indexPath.row].added
        
        if UserData.playlists[indexPath.row].added {
            selectedPlaylists.append(UserData.playlists[indexPath.row].name)
        } else {
            selectedPlaylists = selectedPlaylists.filter {$0 != UserData.playlists[indexPath.row].name}
        }
        
        //Fade the Create button if there aren't any playlists selected
        if selectedPlaylists.count != 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        print(selectedPlaylists)
        
        tableView.reloadData()
    }
    
    @IBAction func createButton(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "isOwner")
        UserDefaults.standard.set(pin, forKey: "station")
        self.performSegue(withIdentifier: "ownerStation", sender: self)
//        dismiss(animated: false, completion: nil)
        
        saveStation()
        
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
            
            randomPin = randomPin + alphabet[randomInt] + " "
        }
        
        return randomPin
        
    }
    
    func getAllSongs(offset: Int) {
        let header = ["Authorization": "Bearer \(UserData.accessToken!)"]
        let parameters = ["offset": "\(offset)"]
        
//        for x in 0..<UserData.playlists.count {
            Alamofire.request("https://api.spotify.com/v1/playlists/\(UserData.playlists[13].id)/tracks", method: .get, parameters: parameters, headers: header)
                .responseArray(keyPath: "items") { (response: DataResponse<[Song]>) in
                    if response.result.isSuccess {
                        
                        print("Success! Getting next 100 songs for '\(UserData.playlists[13].name)'")
                        
                        let songArray = response.result.value!;
                        
                        // Get next 100 songs for the playlist (Spotify has a 100-song request limit for their API)
                        var count = offset + 1
                        for song in songArray {
                            print("\(count).\t\"\(song.name!)\" - \(song.artist!) (\(song.id!))")
                            count += 1
                        }
                        
                        // If 100 songs have been grabbed but there are still songs remaining in the playlist
                        if (UserData.playlists[13].totalSongs - offset) > self.defaultLimit {
                            self.getAllSongs(offset: offset + 100)
                        }
                        else {
                            print("Got all songs for '\(UserData.playlists[13].name)'")
                        }
                        
                    }
                    else {
                        print("Error: \(String(describing: response.result.error!))")
                    }
            }
//        }
    }
    
    //Save station to Firebase
    func saveStation() {
        
        let addStation = Database.database().reference().child("Stations")
        let timestamp = "\(Date())"
        var arrayOfPlaylists = [[String : Any]]()
        
        let songDict = ["Name": "Say It Ain't So",
                        "Artist": "Weezer",
                        "ID": "Jdjs9Djs",
                        "User": "ldimuro"] as [String : Any]
        
        //Iterates through each selected playlist and creates an array of playlist dictionaries
        for each in selectedPlaylists {
            let playlistDict = ["Name": each,
                                "Songs": [songDict, songDict, songDict, songDict],
                                "ID": "aDfs45gsD",
                                "Owner": "ldimuro"] as [String : Any]
            
            arrayOfPlaylists.append(playlistDict)
        }
        
        //The final dictionary of station
        let postDictionary = ["Owner": "ldimuro",
                              "Users": [],
                              "Playlists": arrayOfPlaylists,
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
    
//    func getPlaylists() {
//
//        for x in 0..<data.count {
//            let playlist = AddPlaylist()
//
//            playlist.name = data[x]
//            playlist.genre = genre[x]
//            playlist.added = false
//
//            playlistArray.append(playlist)
//        }
//    }
    
}

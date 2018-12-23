//
//  AddStationViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase

class AddStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var playlistTable: UITableView!
    
    var pin: String?
    let data = ["Lou's Playlist", "for you", "Wine Night", "Discover Weekly", "Sleep", "Mindmelt"]
    let genre = ["Indie", "Pop", "Indietronica", "Indie Rock", "Chill", "Psychedelic"]
    var playlistArray = [AddPlaylist]()
    var selectedPlaylists = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPlaylists()
        
        playlistTable.delegate = self
        playlistTable.dataSource = self
        playlistTable.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let formattedPin = randomPin()
        
        pin = formattedPin.replacingOccurrences(of: " ", with: "") // get rid of the spaces in-between each character
        
        pinLabel.text = formattedPin
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTable.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        cell.textLabel?.text = playlistArray[indexPath.row].name
        cell.detailTextLabel?.text = playlistArray[indexPath.row].genre
        
        //Check to see if a playlist has been selected
        if playlistArray[indexPath.row].added == true {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        playlistArray[indexPath.row].added = !playlistArray[indexPath.row].added
        
        if playlistArray[indexPath.row].added {
            selectedPlaylists.append(playlistArray[indexPath.row].name)
        } else {
            selectedPlaylists = selectedPlaylists.filter {$0 != playlistArray[indexPath.row].name}
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
            
            randomPin = randomPin + alphabet[randomInt] + " "
        }
        
        return randomPin
        
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
    
    func getPlaylists() {
        
        for x in 0..<data.count {
            let playlist = AddPlaylist()
            
            playlist.name = data[x]
            playlist.genre = genre[x]
            playlist.added = false
            
            playlistArray.append(playlist)
        }
    }
    
    

}

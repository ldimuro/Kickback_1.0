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
import JGProgressHUD

class AddStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var playlistTable: UITableView!
    
    var pin: String?
    var loadingPlaceholderView = LoadingPlaceholderView()
    let data = ["Lou's Playlist", "for you", "Wine Night", "Discover Weekly", "Sleep", "Mindmelt"]
    let genre = ["Indie", "Pop", "Indietronica", "Indie Rock", "Chill", "Psychedelic"]
//    var playlistArray = [AddPlaylist]()
    var arrayOfPlaylists = [[String : Any]]()
    var selectedPlaylists = [Playlist]()
//    var songArray = [Song]()
    var songDictArray = [[String : Any]]()
    var defaultOffset = 0
    var defaultLimit = 100
    var playlistCount = 0
    let hud = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistTable.delegate = self
        playlistTable.dataSource = self
//        playlistTable.tableFooterView = UIView()
        
        // Initialize all playlists to be unchosen on loading
        for each in UserData.playlists {
            each.added = false
        }
        
        hud.textLabel.text = "Loading Playlists"
        hud.show(in: self.view)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        selectedPlaylists.removeAll()
        songDictArray.removeAll()
        arrayOfPlaylists.removeAll()
        UserData.songs.removeAll()
        UserData.playlists.removeAll()
        UserData.queue.removeAll()
        
        let formattedPin = randomPin()
        pin = formattedPin.replacingOccurrences(of: " ", with: "") // get rid of the spaces in-between each character
        UserData.stationPin = pin
        pinLabel.text = formattedPin
        
        AppDelegate().initiateSession() // Start playing Spotify music
        
        // PAUSE FOR 4 SECONDS TO ALLOW TIME FOR COMMUNICATION WITH FIREBASE
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            
            repeat {
                self.playlistTable.reloadData()
                self.hud.dismiss()
            } while UserData.accessToken == nil
            
//            self.getAllSongs(offset: self.defaultOffset, id: )
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistTable.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        
        cell.textLabel?.text = UserData.playlists[indexPath.row].name
        cell.detailTextLabel?.text = UserData.playlists[indexPath.row].owner
        
//        cell.textLabel?.text = playlistArray[indexPath.row].name
//        cell.detailTextLabel?.text = playlistArray[indexPath.row].genre
        
        // Check to see if a playlist has been selected
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
            
            let newPlaylist = Playlist()
            
            newPlaylist.name = UserData.playlists[indexPath.row].name
            newPlaylist.owner = UserData.playlists[indexPath.row].owner
            newPlaylist.totalSongs = UserData.playlists[indexPath.row].totalSongs
            newPlaylist.id = UserData.playlists[indexPath.row].id
            
            selectedPlaylists.append(newPlaylist)
        } else {
            selectedPlaylists = selectedPlaylists.filter {$0.id != UserData.playlists[indexPath.row].id}
        }
        
        // Fade the Create button if there aren't any playlists selected
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
        
        // Loops through all selected playlists and grabs all the songs from each
        for playlist in selectedPlaylists {
            getAllSongs(offset: defaultOffset, playlist: playlist)
        }
        
//        saveStation()
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
    
    func getAllSongs(offset: Int, playlist: Playlist) {
        let header = ["Authorization": "Bearer \(UserData.accessToken!)"]
        let parameters = ["offset": "\(offset)"]
        
        Alamofire.request("https://api.spotify.com/v1/playlists/\(playlist.id)/tracks", method: .get, parameters: parameters, headers: header)
            .responseArray(keyPath: "items") { (response: DataResponse<[Song]>) in
                if response.result.isSuccess {
                    
                    print("Success! Getting next 100 songs for '\(playlist.name)'")
                    
                    let songArray = response.result.value!;
                    
                    // Get next 100 songs for the playlist (Spotify has a 100-song request limit for their API)
                    var count = offset + 1
                    for song in songArray {
                        
                        // Creates a new dictionary of the song and add it to an array
                        let songDict = ["Name": "\(song.name!)",
                                        "Artist": "\(song.artist!)",
                                        "ID": "\(song.id!)",
                                        "Album Art": "\(song.art!)",
                                        "User": UserData.username!,
                                        "Symbol": UserData.symbol!] as [String : Any]
                        
//                        self.songDictArray.append(songDict)
                        playlist.songDict.append(songDict)
                        
                        // Creates a new instance of the Song class and adds it to UserData songs
                        let newSong = Song()
                        newSong.name = song.name
                        newSong.artist = song.artist
                        newSong.id = song.id
                        newSong.art = song.art
                        newSong.owner = UserData.username
                        newSong.symbol = UserData.symbol
                        
                        UserData.songs.append(newSong)
                        playlist.songs.append(newSong)
                        
                        print("\(count).\t\(newSong.name!) - \(newSong.artist!)")
                        
                        count += 1
                    }
                    
                    // If 100 songs have been grabbed but there are still songs remaining in the playlist
                    if (playlist.totalSongs - offset) > self.defaultLimit {
                        self.getAllSongs(offset: offset + 100, playlist: playlist)
                    }
                    else {
                        print("Got all songs for '\(playlist.name)'")
                        self.playlistCount += 1
                        
                        let playlistDict = ["Name": playlist.name,
                                            "Songs": playlist.songDict,
                                            "ID": playlist.id,
                                            "Owner": UserData.username!,
                                            "Symbol": UserData.symbol!] as [String : Any]
                        
                        self.arrayOfPlaylists.append(playlistDict)
                        
                        // When all playlists have been processed
                        if self.playlistCount >= self.selectedPlaylists.count {
                            print("GOT ALL PLAYLISTS")
                            self.saveStation()
//                            self.getProfile()
                        }
                    }
                }
                else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
    }
    
    //Save station to Firebase
    func saveStation() {
        
        let addStation = Database.database().reference().child("Stations")
        let timestamp = "\(Date())"
        
        let nowPlayingDict = ["Name": "N/A",
                              "Artist": "N/A",
                              "Album Art": "N/A",
                              "ID": "N/A"]
        
        //The final dictionary of station
        let postDictionary = ["Owner": "ldimuro",
                              "Now Playing": nowPlayingDict,
                              "Users": [],
                              "Playlists": arrayOfPlaylists,
                              "Queue": [],
                              "Timestamp": timestamp] as [String : Any]
        
        addStation.child(pin!).setValue(postDictionary) {
            (error, reference) in
            
            if(error != nil) {
                print(error!)
            }
            else {
                print("Station saved successfully")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.generateInitQueue()
                }
            }
        }
    }
    
    func generateInitQueue() {
        var remainingSongs = UserData.songs
        var queue = [Song]()
        
        print("\nQUEUE:")
        
        while remainingSongs.count > 0 {
            let randomNum = Int.random(in: 0...(remainingSongs.count - 1))
            queue.append(remainingSongs[randomNum])
            
            print("\(remainingSongs[randomNum].name!) - \(remainingSongs[randomNum].artist!)")
            
            remainingSongs.remove(at: randomNum)
        }
        
        print("FINISHED BUILDING QUEUE")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            UserData.queue = queue
            
            // Update initial "Now Playing" song
            let userRef = Database.database().reference().child("Stations").child(UserData.stationPin!)
            let post = ["Name": UserData.queue[0].name,
                        "Artist": UserData.queue[0].artist,
                        "ID": UserData.queue[0].id,
                        "Album Art": UserData.queue[0].art,
                        "User": UserData.queue[0].owner,
                        "Symbol": UserData.queue[0].symbol]
            
            let childUpdates = ["/Now Playing": post]
            userRef.updateChildValues(childUpdates)
            
            NowPlayingData.songName = UserData.queue[0].name!
            NowPlayingData.songCode = UserData.queue[0].id!
            NowPlayingData.artistName = UserData.queue[0].artist!
            NowPlayingData.albumCoverURL = UserData.queue[0].art!
            NowPlayingData.user = UserData.queue[0].owner!
            NowPlayingData.symbol = UserData.queue[0].symbol!
            
            UserData.queue.remove(at: 0)
            print("SONG REMOVED FROM QUEUE")
            
            NowPlayingData.songChanged = true
        }
    }
    
}

//
//  AppDelegate.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    var window: UIWindow?
    
    let SpotifyClientID = "8a64ef11e63d47deb60042098a944a08"
    let SpotifyRedirectURL = URL(string: "kickbackLouD-start://kickback-callback")!
    var songName = ""
    var artistName = ""
    var songCode = ""
    var albumArtURL = ""
    var accessToken = ""
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "https://cliff-sagittarius.glitch.me/api/token")
        configuration.tokenRefreshURL = URL(string: "https://cliff-sagittarius.glitch.me/api/refresh_token")
        
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self

        return appRemote
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
//        let x = true
//
//        if x {
//            let requestedScopes: SPTScope = [.appRemoteControl]
//
//            self.sessionManager.initiateSession(with: requestedScopes, options: .default)
//
//            print("MUSIC STARTS")
//        }
        
        return true
    }
    
    func initiateSession() {
        let requestedScopes: SPTScope = [.appRemoteControl, .playlistReadPrivate, .playlistReadCollaborative]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
        print("MUSIC STARTS")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        self.sessionManager.application(app, open: url, options: options)
        
        return true
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("INITIATED SUCCESSFULLY", session)
        
        self.appRemote.connectionParameters.accessToken = session.accessToken
        self.appRemote.connect()
        
        accessToken = session.accessToken
        UserData.accessToken = session.accessToken
        
        //GET USER PLAYLISTS
        let header = ["Authorization": "Bearer \(accessToken)"]
        let parameters = ["limit": "50"]
        
        Alamofire.request("https://api.spotify.com/v1/me/playlists", method: .get, parameters: parameters, headers: header)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    print("Success! Got the data")
                    let dataJSON : JSON = JSON(response.result.value!)
                    
                    self.getPlaylists(json: dataJSON)
                    self.getProfile()
                    
                }
                else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
        
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("SESSION FAILED", error)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("RENEWED", session)
    }

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("CONNECTION ESTABLISHED")

        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.pause(nil) // Pause Spotify
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
        
        

        // Want to play a new track?
        // self.appRemote.playerAPI?.play("spotify:track:13WO20hoD72L0J13WTQWlT", callback: { (result, error) in
        //     if let error = error {
        //         print(error.localizedDescription)
        //     }
        // })
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("DISCONNECTED", error!)
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("FAILED CONNECTION ATTEMPT", error!)
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
        print("track.name", playerState.track.name)
        print("track.artist.name", playerState.track.artist.name)
//        print("isPaused", playerState.isPaused)
//        print("track.uri", playerState.track.uri)
//        print("track.imageIdentifier", playerState.track.imageIdentifier)
//        print("track.album.name", playerState.track.album.name)
//        print("track.isSaved", playerState.track.isSaved)
//        print("playbackSpeed", playerState.playbackSpeed)
//        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
//        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
//        print("playbackPosition", playerState.playbackPosition)
        
        songName = playerState.track.name
        songCode = playerState.track.uri.replacingOccurrences(of: "spotify:track:", with: "")
        artistName = playerState.track.artist.name
        
        NowPlayingData.songName = songName
        NowPlayingData.songCode = songCode
        NowPlayingData.artistName = artistName
        
        let albumID = playerState.track.album.uri.replacingOccurrences(of: "spotify:album:", with: "")
        
        getAlbumArt(albumID: albumID)
        
    }
    
    func getProfile() {
        let header = ["Authorization": "Bearer \(accessToken)"]
        
        Alamofire.request("https://api.spotify.com/v1/me", method: .get, parameters: [:], headers: header)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    print("Success! Got the data")
                    let dataJSON : JSON = JSON(response.result.value!)
                    
                    UserData.username = dataJSON["id"].string!
                    print("USERNAME: \(UserData.username!)")
                    
                }
                else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
    }
    
    func getAlbumArt(albumID: String) {
        
        let header = ["Authorization": "Bearer \(accessToken)"]
        let getAlbumArt = "https://api.spotify.com/v1/albums/" + albumID
        
        print(getAlbumArt)
        
        Alamofire.request(getAlbumArt, method: .get, parameters: [:], headers: header)
            .responseJSON { response in
                if response.result.isSuccess {
                    
//                    print("Success! Got the data")
                    let dataJSON : JSON = JSON(response.result.value!)
                    
                    if let url = dataJSON["images"][0]["url"].string {
                        self.albumArtURL = url
                        NowPlayingData.albumCoverURL = url
                        
                        print("URL: \(url)")
                        
                        let stationVC: StationViewController = StationViewController()
                        if UserDefaults.standard.string(forKey: "station") != "none" {
//                            stationVC.updateNowPlaying(name: self.songName, artist: self.artistName, id: self.songCode, art: url)
                        }
                    }
                    
                } else {
                    print("Error: \(String(describing: response.result.error!))")
                }
        }
    }
    
    func getPlaylists(json: JSON) {
        
        var x = 0
        
        while (json["items"][x]["name"].string != nil) {
            
            let playlist = Playlist()
            
            let name = json["items"][x]["name"].string!
            let owner = json["items"][x]["owner"]["id"].string!
            let songs = json["items"][x]["tracks"]["href"].string!
            let id = json["items"][x]["id"].string!
            let totalSongs = json["items"][x]["tracks"]["total"].int!
            
            playlist.name = name
            playlist.owner = owner
            playlist.id = id
            playlist.totalSongs = totalSongs
            
            UserData.playlists.append(playlist)
            
            print("#\(x). \(playlist.name) - \(playlist.owner)")
            
            x += 1
            
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("RESIGN ACTIVE")
        
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        appRemote.delegate = self
//
        if let _ = appRemote.connectionParameters.accessToken {
            print("BECAME ACTIVE") // DOES print

            DispatchQueue.main.async {[weak self] in
                self?.appRemote.connect()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// LIST OF USER DEFAULTS:
// "station"    =   PIN or "none"
// "isOwner"    =   True/False

struct NowPlayingData {
    static var songName = ""
    static var songCode = ""
    static var artistName = ""
    static var albumCoverURL = ""
    static var user = ""
    static var symbol = ""
    
}

struct UserData {
    static var playlists = [Playlist]()
    static var songs = [Song]()
    static var queue = [Song]()
    static var accessToken : String?
    static var stationPin : String?
    static var username : String?
    static var symbol : String?
}

//Adds the click away from keyboard functionality for use in any view controller with self.hideKeyboard when tapped around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

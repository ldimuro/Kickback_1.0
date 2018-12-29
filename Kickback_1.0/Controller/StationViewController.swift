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

class StationViewController: UIViewController, UIApplicationDelegate {
    
    // MARK: SPOTIFY VARIABLES
    
//    fileprivate let SpotifyClientID = "8a64ef11e63d47deb60042098a944a08"
//    fileprivate let SpotifyRedirectURL = URL(string: "kickback-start://callback")!
//    
//    lazy var configuration: SPTConfiguration = {
//        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
//        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
//        // otherwise another app switch will be required
//        configuration.playURI = ""
//        
//        // Set these url's to your backend which contains the secret to exchange for an access token
//        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
//        configuration.tokenSwapURL = URL(string: "https://cliff-sagittarius.glitch.me/api/token")
//        configuration.tokenRefreshURL = URL(string: "https://cliff-sagittarius.glitch.me/api/refresh_token")
//        
//        return configuration
//    }()
//    
//    lazy var sessionManager: SPTSessionManager = {
//        let manager = SPTSessionManager(configuration: configuration, delegate: self)
//        return manager
//    }()
//    
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
//        appRemote.delegate = self
//        
//        return appRemote
//    }()
//    
//    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    
    // MARK: VARIABLES
    
    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var blurredAlbumArt: UIImageView!
    let username = "testUser"
    let stationPin = UserDefaults.standard.string(forKey: "station")
    let isOwner = UserDefaults.standard.bool(forKey: "isOwner")
    var userArray = [String]()
    var arrayOfUsers = [[String : Any]]()
    var accessToken = ""

    //MARK: VIEW DID LOAD/APPEAR
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = stationPin
        
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
        // If user is the owner, begins a Spotify session
//        else {
//
//            let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
//
//            if #available(iOS 11, *) {
//                // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
//                sessionManager.initiateSession(with: scope, options: .clientOnly)
//                print("SPOTIFY SESSION STARTED")
//            } else {
//                // Use this on iOS versions < 11 to use SFSafariViewController
//                sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
//                print("SPOTIFY SESSION STARTED")
//            }
//        }
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        self.sessionManager.application(app, open: url, options: options)
//
//        return true
//    }
    
    //MARK: SPOTIFY ACTIONS
    
//    func update(playerState: SPTAppRemotePlayerState) {
//        if lastPlayerState?.track.uri != playerState.track.uri {
//            fetchArtwork(for: playerState.track)
//        }
//        lastPlayerState = playerState
////        trackLabel.text = playerState.track.name
//        if playerState.isPaused {
////            pauseAndPlayButton.setImage(UIImage(named: "play"), for: .normal)
//        } else {
////            pauseAndPlayButton.setImage(UIImage(named: "pause"), for: .normal)
//        }
//    }
//
//    func fetchArtwork(for track:SPTAppRemoteTrack) {
//        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
//            if let error = error {
//                print("Error fetching track image: " + error.localizedDescription)
//            } else if let image = image as? UIImage {
//                self?.albumArt.image = image
//                self?.blurredAlbumArt.image = image
//            }
//        })
//    }
//
//    func fetchPlayerState() {
//        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
//            if let error = error {
//                print("Error getting player state:" + error.localizedDescription)
//            } else if let playerState = playerState as? SPTAppRemotePlayerState {
//                print("FETCHED PLAYER STATE")
//                self?.update(playerState: playerState)
//            }
//        })
//    }
    
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
//    }
//    
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
//    }
//    
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        print("SESSION INITIATED")
//        
//        accessToken = session.accessToken
//        
//        self.appRemote.connectionParameters.accessToken = session.accessToken
//        self.appRemote.connect()
//    }
//
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
////        updateViewBasedOnConnected()
//        print("CONNECTION ESTABLISHED")
//        self.appRemote.playerAPI?.delegate = self
//        self.appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//            if let error = error {
//                print("Error subscribing to player state:" + error.localizedDescription)
//            }
//        })
//        fetchPlayerState()
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
////        updateViewBasedOnConnected()
//        print("DISCONNECTED")
//        lastPlayerState = nil
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
////        updateViewBasedOnConnected()
//        print("FAILED")
//        lastPlayerState = nil
//    }
//
//    func applicationWillResignActive(_ application: UIApplication) {
//        if self.appRemote.isConnected {
//            print("CONNECTION RESIGNED")
//            self.appRemote.disconnect()
//        }
//    }
//
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        print("PLAYER STATE CHANGED")
//        update(playerState: playerState)
//
//        print("track.name", playerState.track.name)
//        print("track.imageIdentifier", playerState.track.imageIdentifier)
//        print("track.artist.name", playerState.track.artist.name)
//        print("track.album.name", playerState.track.album.name)
//    }
//
//    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
//        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
//        controller.addAction(action)
//        present(controller, animated: true)
//    }
    
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

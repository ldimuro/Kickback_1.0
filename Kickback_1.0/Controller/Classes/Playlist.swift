//
//  Playlist.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 1/2/19.
//  Copyright © 2019 Lou DiMuro. All rights reserved.
//

import Foundation

class Playlist {
    var name : String = ""
    var owner : String = ""
    var songs = [Song]()
    var songDict = [[String : Any]]()
    var id : String = ""
    var symbol : String = ""
    var totalSongs = 0
    var added = false
}

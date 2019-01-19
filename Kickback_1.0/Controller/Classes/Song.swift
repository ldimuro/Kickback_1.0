//
//  Song.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 1/2/19.
//  Copyright © 2019 Lou DiMuro. All rights reserved.
//

import Foundation
import ObjectMapper

class Song: Mappable {
    
    var name : String?
    var artist : String?
    var id : String?
    var owner : String?
    var symbol : String?
    var art : String?
    
    init() {
        self.name = nil
        self.artist = nil
        self.id = nil
        self.owner = nil
        self.symbol = nil
        self.art = nil
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["track.name"]
        artist <- map["track.artists.0.name"]
        id <- map["track.id"]
        art <- map["track.album.images.0.url"]
    }
}

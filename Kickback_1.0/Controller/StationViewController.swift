//
//  StationViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/18/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "D S S O"
        
    }
    
    @IBAction func exitStationPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

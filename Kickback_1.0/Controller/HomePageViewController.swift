//
//  HomePageViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var addStationButton: UIBarButtonItem!
    @IBOutlet weak var homeNavigator: UISegmentedControl!
    @IBOutlet weak var enterCodeView: UIView!
    @IBOutlet weak var nowPlayingView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterCodeView.isHidden = false
        nowPlayingView.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch homeNavigator.selectedSegmentIndex {
        case 0:
            enterCodeView.isHidden = false
            nowPlayingView.isHidden = true
//            historyView.isHidden = true
//            popularView.isHidden = false
            print("ENTER CODE")
        case 1:
            enterCodeView.isHidden = true
            nowPlayingView.isHidden = false
//            historyView.isHidden = false
//            popularView.isHidden = true
            print("NOW PLAYING")
        default:
            break;
        }
    }
    
    

}

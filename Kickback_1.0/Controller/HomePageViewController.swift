//
//  HomePageViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class HomePageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var addStationButton: UIBarButtonItem!
    @IBOutlet weak var pinTextfield: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = "ldimuro"
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set("none", forKey: "station")
        UserDefaults.standard.set(false, forKey: "isOwner")

        errorLabel.isHidden = true
        pinTextfield.delegate = self
        pinTextfield.defaultTextAttributes.updateValue(5.0, forKey: NSAttributedString.Key.kern)
        enterButton.layer.cornerRadius = 5
        
        //The Enter button is initially faded
        if (pinTextfield.text?.isEmpty)! {
            self.enterButton.isEnabled = false
            self.enterButton.backgroundColor = UIColor.lightGray
        }
        
        self.hideKeyboardWhenTappedAround()
    }
    
    //If the PIN textfield is empty, the Enter button will be faded
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (pinTextfield.text! as NSString).replacingCharacters(in: range, with: string)
        let count = text.count
        let range = string.rangeOfCharacter(from: NSCharacterSet.letters)
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        self.pinTextfield.backgroundColor = UIColor.white
        errorLabel.isHidden = true
        
        //Only accepts letters and the backspace button as inputs
        if (range != nil) || (isBackSpace == -92) {
            if !text.isEmpty && text.count >= 4 {
                enterButton.isEnabled = true
                enterButton.backgroundColor = UIColor(red: 0.0196, green: 0.4784, blue: 1.0, alpha: 1.0)
            } else {
                enterButton.isEnabled = false
                enterButton.backgroundColor = UIColor.lightGray
            }
            
            //User can only type 4 characters in the textfield
            return count <= 4
        }
        else {
            return false
        }
        
        
    }
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        findStation()
        
    }
    
    //Looks for a station that matches the entered PIN
    func findStation() {
        
        var stationFound = false
        let stationRef = Database.database().reference().child("Stations")
        
        stationRef.observe(.value) { (snapshot) in
            
            for snap in snapshot.children {
                
                let snapKey = snap as! DataSnapshot
                let key = snapKey.key as String
                
                if key == self.pinTextfield.text! {
                    stationFound = true
                    print("STATION '\(key)' FOUND!")
                    self.pinTextfield.text = ""
                    self.enterButton.isEnabled = false
                    self.enterButton.backgroundColor = UIColor.gray
                    
                    UserDefaults.standard.set(key, forKey: "station")
                    UserData.stationPin = key
                    
                    self.performSegue(withIdentifier: "goToStation", sender: self)
                }
            }
        }
        
        //DELAYS FOR A SECOND TO GIVE TIME TO COMMUNICATE INFORMATION WITH SERVER
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // in a second...
            if stationFound == false {
                print("Station not found")
                self.errorLabel.isHidden = false
                self.pinTextfield.text = ""
                self.pinTextfield.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
                self.enterButton.isEnabled = false
                self.enterButton.backgroundColor = UIColor.gray
            }
        }
    }
    

}

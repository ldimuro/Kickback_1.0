//
//  EnterPinViewController.swift
//  Kickback_1.0
//
//  Created by Lou DiMuro on 12/17/18.
//  Copyright © 2018 Lou DiMuro. All rights reserved.
//

import UIKit

class EnterPinViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var pinTextfield: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //The Enter button is initially faded
        pinTextfield.delegate = self
        if (pinTextfield.text?.isEmpty)! {
            self.enterButton.isEnabled = false
            self.enterButton.backgroundColor = UIColor.gray
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
        
        //Only accepts letters and the backspace button as inputs
        if (range != nil) || (isBackSpace == -92) {
            if !text.isEmpty && text.count >= 4 {
                enterButton.isEnabled = true
                enterButton.backgroundColor = UIColor(red: 0.0196, green: 0.4784, blue: 1.0, alpha: 1.0)
            } else {
                enterButton.isEnabled = false
                enterButton.backgroundColor = UIColor.gray
            }
            
            //User can only type 4 characters in the textfield
            return count <= 4
        }
        else {
            return false
        }
        
        
    }
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        
        print("*\(pinTextfield.text!)*")
        
        pinTextfield.text = ""
        enterButton.isEnabled = false
        enterButton.backgroundColor = UIColor.gray
    }
    
    
    
}

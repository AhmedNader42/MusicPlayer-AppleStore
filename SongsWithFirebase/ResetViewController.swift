//
//  File.swift
//  SongsWithFirebase
//
//  Created by Admin on 4/8/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//


import UIKit
import Foundation
import Firebase
class ResetViewController : UIViewController
{
    
    /*************************************************************
     *                                                           *
     *                         Outlets                           *
     *                                                           *
     *************************************************************/
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var spinner          : UIActivityIndicatorView!
    @IBOutlet weak var resetButton      : UIButton!
    
    
    /*************************************************************
     *                                                           *
     *                         IBAction                          *
     *                                                           *
     *************************************************************/
    @IBAction func resetButton(_ sender: UIButton) {
        
        // Start the spinner to indicate loading and disable the button.
        spinner.startAnimating()
        resetButton.isEnabled = false
        resetButton.alpha = 0.5
        
        // Make sure the email is not empty.
        if !emailTextField.hasText {
            // Stop the button and reenable the button.
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.resetButton.isEnabled = true
                self.resetButton.alpha = 1
            }
            // Show a popup with the error.
            showError(Title: "Reset Error", Message: "Please Enter the email!")
        }
        else{
            // Send a reset password to the email in the text field.
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!, completion: {
                (error) in
                
                // For the popup at the end indicating either error or success.
                var title = ""
                var message = ""
                
                if error != nil{
                    // Stop the spinner and reenable the button.
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.resetButton.isEnabled = true
                        self.resetButton.alpha = 1
                    }
                    // Set the title to indicate error.
                    title = "Reset ERROR!"
                    message = (error?.localizedDescription)!
                }
                else{
                    // Stop the spinner and reenable the button.
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.resetButton.isEnabled = true
                        self.resetButton.alpha = 1
                    }
                    // Set the title and message to indicate success.
                    title = "Reset Success!"
                    message = "Password was reset successfully check your e-mail"
                    self.emailTextField.text = ""
                }
                
                // Show the result of processing the email.
                self.showError(Title: title, Message: message)
            })
        }
    }
    
    /*************************************************************
     *                                                           *
     *                         Error                             *
     *                                                           *
     *************************************************************/
    /// Shows an error popup with a given message and title
    ///
    /// - Parameters:
    ///   - title: The title displayed at the top
    ///   - message: The message displayed withtin the body
    func showError(Title title: String , Message message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


/*************************************************************
 *                                                           *
 *                         Keyboard                          *
 *                                                           *
 *************************************************************/
extension ResetViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ResetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}


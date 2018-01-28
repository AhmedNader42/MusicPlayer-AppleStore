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

class LoginViewController: UIViewController
{
    // MARK: - Outlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField   : UITextField!
    @IBOutlet weak var spinner          : UIActivityIndicatorView!
    @IBOutlet weak var loginButton      : UIButton!
    

    
    // MARK: - Identifiers
    struct identifiers {
        static let musicViewController = "MusicViewController"
        static let loginPersistence    = "login"
    }
    
    // MARK: - Actions
    @IBAction func loginButton(_ sender: UIButton) {
        
        // Start animating the spinner to indicate loading and disable the button.
        spinner.startAnimating()
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        
        // Check the fields are not empty
        if !emailTextField.hasText || !passwordTextField.hasText {
            showError(Title: "LogIn Error", Message: "Please Enter the email and password")
            // Stop the spinner and reenable the button to try again.
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1
            }
        }
        else{
            FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){
                (user,error) in
                
                if error != nil{
                    
                    // Stop animating and reenable the button
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.loginButton.isEnabled = true
                        self.loginButton.alpha = 1
                    }
                    
                    // Show an error popup with the message
                    self.showError(Title: "SignIn Error", Message: (error?.localizedDescription)!)
                }
                else{
                    // Set the login status to true
                    UserDefaults.standard.object(forKey: identifiers.loginPersistence)
                    UserDefaults.standard.set(true, forKey: identifiers.loginPersistence)
                    
                    // Stop the spinner and reenable the button.
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.loginButton.isEnabled = true
                        self.loginButton.alpha = 1
                    }
                    
                    // Go to the music player after a sucessful login.
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers.musicViewController)
                    self.present(viewController!, animated: true, completion: nil)
                }
            }
        }
        
        
        
        
    }
    // MARK: - Error Alert
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

// MARK: - Keyboard dismiss
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}


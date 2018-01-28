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

class SignUpViewController: UIViewController
{
    // MARK: - Outlets
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var spinner          : UIActivityIndicatorView!
    @IBOutlet weak var signupButton      : UIButton!
    
    // MARK: - Identifiers
    struct identifiers {
        static let musicViewController = "MusicViewController"
        static let loginPersistence    = "login"
    }
    
    
    
    // MARK: - Actions
    @IBAction func signupButton(_ sender: UIButton) {
        
        // Start animating the spinner and disable the button.
        spinner.startAnimating()
        signupButton.isEnabled = false
        signupButton.alpha = 0.5
        
        // Make sure the field is not empty
        if !emailTextField.hasText {
            // Stop the spinner and reenable the button.
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.signupButton.isEnabled = true
                self.signupButton.alpha = 1
            }
            // Show an error popup.
            showError(Title: "SignUp Error!", Message: "Please Enter your email and password")
        }
        else{
            // Authenticate the user with the given email and password.
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){
                (user,error) in
                
                if error != nil{
                    // Stop the spinner and reenable the button
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.signupButton.isEnabled = true
                        self.signupButton.alpha = 1
                    }
                    // Show an error popup.
                    self.showError(Title: "SignUp Error", Message: (error?.localizedDescription)!)
                }
                else {
                    // Set the login status to true
                    UserDefaults.standard.object(forKey: identifiers.loginPersistence)
                    UserDefaults.standard.set(true, forKey: identifiers.loginPersistence)
                    
                    // Stop the spinner and reenable the button.
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.signupButton.isEnabled = true
                        self.signupButton.alpha = 1
                    }
                    
                    // Go to the MusicViewController
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers.musicViewController)
                    self.present(viewController!,animated: true,completion: nil)
                    
                }
                
            }
        }
    }
    // MARK: - Alert
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




// MARK: - Keyboard Dismiss
extension SignUpViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}


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
        
        spinner.startAnimating()
        resetButton.isEnabled = false
        resetButton.alpha = 0.5
        
        
        if emailTextField.text == "" {
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.resetButton.isEnabled = true
                self.resetButton.alpha = 1
            }
            
            showError(Title: "Reset Error", Message: "Please Enter the email!")
        }
        else{
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!, completion: {
                (error) in
                
                
                var title = ""
                var message = ""
                
                if error != nil{
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.resetButton.isEnabled = true
                        self.resetButton.alpha = 1
                    }
                    
                    title = "Reset ERROR!"
                    message = (error?.localizedDescription)!
                }
                else{
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.resetButton.isEnabled = true
                        self.resetButton.alpha = 1
                    }
                    
                    title = "Reset Success!"
                    message = "Password was reset successfully check your e-mail"
                    self.emailTextField.text = ""
                }
                self.showError(Title: title, Message: message)
            })
        }
    }
    
    /*************************************************************
     *                                                           *
     *                         Error                             *
     *                                                           *
     *************************************************************/
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


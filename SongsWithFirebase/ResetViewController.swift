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
    
    
    /*************************************************************
     *                                                           *
     *                         IBAction                          *
     *                                                           *
     *************************************************************/
    @IBAction func resetButton(_ sender: UIButton) {
        if emailTextField.text == ""{
            showError(Title: "Reset Error", Message: "Please Enter the email!")
        }
        else{
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailTextField.text!, completion: {
                (error) in
                var title = ""
                var message = ""
                
                if error != nil{
                    title = "Reset ERROR!"
                    message = (error?.localizedDescription)!
                }
                else{
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


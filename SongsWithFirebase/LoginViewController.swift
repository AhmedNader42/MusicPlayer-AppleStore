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
    /*************************************************************
     *                                                           *
     *                         Outlets                           *
     *                                                           *
     *************************************************************/
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
  
    /*************************************************************
     *                                                           *
     *                         IBAction                          *
     *                                                           *
     *************************************************************/
    @IBAction func loginButton(_ sender: UIButton) {
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            showError(Title: "LogIn Error", Message: "Please Enter the email and password")
        }
        else{
            FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){
                (user,error) in
                
                
                if error != nil{
                    self.showError(Title: "SignIn Error", Message: (error?.localizedDescription)!)
                }
                else{
                    print ("Sign in successful")
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
                    self.present(viewController!, animated: true, completion: nil)
                }
            }
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
extension LoginViewController{
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


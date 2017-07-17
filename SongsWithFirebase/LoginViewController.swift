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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField   : UITextField!
    @IBOutlet weak var spinner          : UIActivityIndicatorView!
    @IBOutlet weak var loginButton      : UIButton!
  
    /*************************************************************
     *                                                           *
     *                         IBAction                          *
     *                                                           *
     *************************************************************/
    @IBAction func loginButton(_ sender: UIButton) {
        
        spinner.startAnimating()
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            showError(Title: "LogIn Error", Message: "Please Enter the email and password")
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
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                    
                        self.loginButton.isEnabled = true
                        self.loginButton.alpha = 1
                    }
                    
                    self.showError(Title: "SignIn Error", Message: (error?.localizedDescription)!)
                }
                else{
                    print ("Sign in successful")
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.loginButton.isEnabled = true
                        self.loginButton.alpha = 1
                    }
                    
                    
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


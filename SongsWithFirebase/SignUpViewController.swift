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
    /*************************************************************
     *                                                           *
     *                         Outlets                           *
     *                                                           *
     *************************************************************/
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet weak var spinner          : UIActivityIndicatorView!
    @IBOutlet weak var signupButton      : UIButton!
    
    /*************************************************************
     *                                                           *
     *                         IBAction                          *
     *                                                           *
     *************************************************************/
    @IBAction func signupButton(_ sender: UIButton) {
        
        spinner.startAnimating()
        signupButton.isEnabled = false
        signupButton.alpha = 0.5
        
        
        if emailTextField.text == "" {
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.signupButton.isEnabled = true
                self.signupButton.alpha = 1
            }
            
            showError(Title: "SignUp Error!", Message: "Please Enter your email and password")
        }
        else{
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){
                (user,error) in
                
                if error != nil{
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.signupButton.isEnabled = true
                        self.signupButton.alpha = 1
                    }
                    
                    self.showError(Title: "SignUp Error", Message: (error?.localizedDescription)!)
                }
                else {
                    print("Sign Up was successful")
                    
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.signupButton.isEnabled = true
                        self.signupButton.alpha = 1
                    }
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
                    self.present(viewController!,animated: true,completion: nil)
                    
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


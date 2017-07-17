//
//  ViewController.swift
//  SongsWithFirebase
//
//  Created by Admin on 4/8/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import AVFoundation

class MusicViewController: UIViewController{

    /*************************************************************
     *                                                           *
     *                       Outlets                             *
     *                                                           *
     *************************************************************/
    @IBOutlet var sliderOutlet: UISlider!
    
    
    /*************************************************************
     *                                                           *
     *                       Variables                           *
     *                                                           *
     *************************************************************/
    var player = AVAudioPlayer()
    var songIsChoosed = false
    let songs = ["rollingInTheDeep","Hello","Skyfall","RumorHasIt","TurningTables","SetFireToTheRain","RiverLea","MillionYearsAgo","WaterAndAFlame"]
    

    /*************************************************************
     *                                                           *
     *                        IBAction                           *
     *                                                           *
     *************************************************************/
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        if FIRAuth.auth()?.currentUser != nil{
            do{
                try FIRAuth.auth()?.signOut()
                if songIsChoosed {
                    player.stop()
                }
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(viewController, animated: true, completion: nil)
            }
            catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func playButton(_ sender: UIButton) {
        if songIsChoosed{
            player.play()
        }
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        if songIsChoosed{
            player.pause()
        }
        
    }
    
    @IBAction func sliderButton(_ sender: UISlider) {
        if songIsChoosed{
            player.volume = sliderOutlet.value
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
 *                       TableView methods                   *
 *                                                           *
 *************************************************************/
extension MusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            
            if let songName = cell.textLabel?.text{
                let songPath = Bundle.main.path(forResource: songName, ofType: "mp3")
                
                do{
                    try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: songPath!))
                    songIsChoosed = true
                    player.play()
                }catch {
                    showError(Title: "Error!", Message: "There was an error try again")
                }
            }
        }
    }

}

extension MusicViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return songs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = songs[indexPath.row]
  
        return cell
    }
    
    
}




/*************************************************************
 *                                                           *
 *                         Keyboard                          *
 *                                                           *
 *************************************************************/
extension MusicViewController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MusicViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}




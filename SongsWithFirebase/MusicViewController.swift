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

class MusicViewController: UIViewController {
    
    
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
    var musicPlayer = AVQueuePlayer()
    var songIsChoosed = false
    let songs = ["RollingInTheDeep","Hello","Skyfall","RumorHasIt","TurningTables","SetFireToTheRain","RiverLea","MillionYearsAgo","WaterAndAFlame"]
    var currentlyPlaying = 0
    var isLoggedIn : Bool?
    
    /*************************************************************
     *                                                           *
     *                       Identifiers                         *
     *                                                           *
     *************************************************************/
    struct identifiers {
        static let main                = "Main"
        static let loginViewController = "Login"
        static let loginPersistence   = "login"
    }
    
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
                
                // Set The value of the persistent login to false
                UserDefaults.standard.set(false, forKey: identifiers.loginPersistence)
                
                // Go to the login view Controller
                let viewController = UIStoryboard(name: identifiers.main , bundle: nil).instantiateViewController(withIdentifier: identifiers.loginViewController)
                present(viewController, animated: true, completion: nil)
            }
            catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    // Play Music button
    @IBAction func playButton(_ sender: UIButton) {
        if songIsChoosed{
            player.play()
        }
    }
    // Pause Music button
    @IBAction func pauseButton(_ sender: UIButton) {
        if songIsChoosed{
            player.pause()
        }
        
    }
    // Volume slider
    @IBAction func sliderButton(_ sender: UISlider) {
        if songIsChoosed{
            player.volume = sliderOutlet.value
        }
    }
    
    /*************************************************************
     *                                                           *
     *                        Activity Life Cycle                *
     *                                                           *
     *************************************************************/
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let logged = UserDefaults.standard.value(forKey: identifiers.loginPersistence) {
            isLoggedIn = (logged as! Bool)
        } else {
            isLoggedIn = false
        }
        
        if !isLoggedIn! {

            let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers.loginViewController)
            self.present(viewController!, animated: true, completion: nil)
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
 *                         Music Player                      *
 *                                                           *
 *************************************************************/
extension MusicViewController : AVAudioPlayerDelegate {
    
    func playMusic(SongName name: String,Index index: Int) {
        let songPath = Bundle.main.path(forResource: name, ofType: "mp3")
        
        do{
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: songPath!))
            songIsChoosed = true
            currentlyPlaying = index
            player.play()
        }catch {
            showError(Title: "Error!", Message: "There was an error try again")
        }
        
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        let nextInQueue = (currentlyPlaying + 1) % songs.count
        print("NextInQueue : \(nextInQueue)")
        let songName = songs[nextInQueue]
        
        playMusic(SongName: songName,Index: nextInQueue)
        
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
            
            if let songName = cell.textLabel?.text {
                playMusic(SongName: songName, Index: indexPath.row)
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




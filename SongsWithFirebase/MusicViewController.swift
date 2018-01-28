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
    
    
    // MARK: - Outlets
    @IBOutlet weak var sliderOutlet: UISlider!
    
    // MARK: - Variables
    var musicPlayer = AVQueuePlayer()
    var songIsChoosed = false
    let songs = ["RollingInTheDeep","Hello","Skyfall","RumorHasIt","TurningTables","SetFireToTheRain","RiverLea","MillionYearsAgo","WaterAndAFlame"]
    var isLoggedIn : Bool?
    
    // MARK: - Identifiers
    struct identifiers {
        static let loginViewController = "LoginViewController"
        static let loginPersistence    = "login"
        static let cell                = "Cell"
    }
    
    // MARK: - Actions
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        // Make sure current user exists.
        if FIRAuth.auth()?.currentUser != nil{
            do{
                // Logout the user.
                try FIRAuth.auth()?.signOut()
                // Stop the music before logout.
                if songIsChoosed {
                    musicPlayer.pause()
                }
                
                // Set The value of the persistent login to false.
                UserDefaults.standard.set(false, forKey: identifiers.loginPersistence)
                
                // Go to the login view Controller.
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers.loginViewController)
                present(viewController!, animated: true, completion: nil)
            }
            catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    // Play Music button.
    @IBAction func playButton(_ sender: UIButton) {
        if songIsChoosed{
            musicPlayer.play()
        }
    }
    // Pause Music button.
    @IBAction func pauseButton(_ sender: UIButton) {
        if songIsChoosed{
            musicPlayer.pause()
        }
        
    }
    // Volume slider.
    @IBAction func sliderButton(_ sender: UISlider) {
        // Match the volume with the slider outlet.
        if songIsChoosed {
            musicPlayer.volume = sliderOutlet.value
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        // Skip to the next item in the queue.
        if songIsChoosed {
            musicPlayer.advanceToNextItem()
        }
        // If the queue is empty requeue songs in the array.
        if musicPlayer.items().count == 0 {
            queueMusic()
        }
    }
    
    
    @IBAction func prevButton(_ sender: UIButton) {
    }
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get the persistent login status.
        if let logged = UserDefaults.standard.value(forKey: identifiers.loginPersistence) {
            isLoggedIn = (logged as! Bool)
        } else {
            isLoggedIn = false
        }
        
        // If the user is not logged in go to the login VC.
        if !isLoggedIn! {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifiers.loginViewController)
            self.present(viewController!, animated: true, completion: nil)
        }
        
        // Load the music on startup.
        queueMusic()
        
        // When song ends go to the next.
        musicPlayer.actionAtItemEnd = .advance
    }
    
    // MARK: - Music Queuing
    /// Load the songs array into the queue.
    func queueMusic() {
        for each in songs {
            let songPath = Bundle.main.path(forResource: each, ofType: "mp3")
            let url = URL(fileURLWithPath: songPath!)
            
            musicPlayer.insert(AVPlayerItem(url: url), after: nil)
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



// MARK: - TableView
extension MusicViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath){
            // Get the song name from the tapped cell
            if let songName = cell.textLabel?.text {
                
                // Get the path for the song
                let songPath = Bundle.main.path(forResource: songName, ofType: "mp3")
                // Construct a url with the path
                let url = URL(fileURLWithPath: songPath!)
                
                
                // Prevent queueing the same song multiple times
                if AVPlayerItem(url: url) === musicPlayer.currentItem{
                    
                } else {
                    // Insert the tapped song after the current and advance to play it.
                    musicPlayer.insert(AVPlayerItem(url: url) , after: musicPlayer.currentItem)
                    musicPlayer.advanceToNextItem()
                }
                
                // Play the currently selected song
                musicPlayer.play()
                songIsChoosed = true
            }
        }
    }
    
}

extension MusicViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return songs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifiers.cell)
        
        cell.textLabel?.text = songs[indexPath.row]
        
        return cell
    }
    
    
}




// MARK: - Keyboard Dismiss
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




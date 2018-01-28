//
//  ViewController.swift
//  Apple Store
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    
    
    // MARK: - Variables
    var Results: [Result] = []
    var didSearch         = false
    var isDownloading     = false
    var dataTask          : URLSessionDataTask?
    
    // MARK: - Identifiers
    struct identifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell      = "LoadingCell"
    }
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Match with the height of the Nib
        tableView.rowHeight = 80
        
        //Register Custom Nibs
        let searchResultNib = UINib(nibName: identifiers.searchResultCell ,bundle: nil)
        tableView.register(searchResultNib, forCellReuseIdentifier: identifiers.searchResultCell )
        
        let nothingFoundNib = UINib(nibName: identifiers.nothingFoundCell, bundle: nil)
        tableView.register(nothingFoundNib, forCellReuseIdentifier: identifiers.nothingFoundCell)
        
        let loadingNib = UINib(nibName: identifiers.loadingCell, bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: identifiers.loadingCell)
        
        // Shows the keyboard on startup.
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Alert
    /// Shows an error popup with a given message and title
    ///
    /// - Parameters:
    ///   - title: The title displayed at the top
    ///   - message: The message displayed withtin the body
    func showError(Title title:String , Message message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate{
    
    // Perform search when the search button is clicked.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    /// Search with the text in search bar.
    func performSearch(){
        // Search bar has text in it
        if !(searchBar.text?.isEmpty)! {
            
            // Dismiss the keyboard
            searchBar.resignFirstResponder()
            
            
            didSearch = true
            isDownloading=true
            
            // Initialize the array.
            Results = []
            
            
            tableView.reloadData()
            
            //Cancel previous requests
            dataTask?.cancel()
            
            // Get a valid url with the search text.
            let url = iTunesURL(SearchFor: searchBar.text!)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) {
                data,response,error in
                
                // Check for error
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                // check the server response code.
                else if let httpresponse = response as? HTTPURLResponse , httpresponse.statusCode == 200 {
                    // Turn the JSON Data into a dictionary.
                    if let data = data, let jsonDictionary = parse(json:data) {
                        // Set the results as the result from parsing the dictionary.
                        self.Results = parseDict(dictionary: jsonDictionary)
                        
                        // Reload to show the data.
                        DispatchQueue.main.async {
                            self.isDownloading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                }
                // Show and error.
                DispatchQueue.main.async {
                    self.didSearch = false
                    self.isDownloading = false
                    self.tableView.reloadData()
                    self.showError(Title: "Ooops", Message: "There was an error with iTunes. Try again ")
                }
            }
            dataTask?.resume()
        }
    }
    
    
}


// MARK: - Networking methods
/// Constructs a valid iTunes URL from search text
///
/// - Parameter searchText: The text that will be searched for.
/// - Returns: Valid iTunes URL.
func iTunesURL(SearchFor searchText:String) -> URL{
    
    // Replace with allowed characters only
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    // Put the valid search text in the string.
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
    // Construct the URL and return.
    let url = URL(string: urlString)
    return url!
}





// MARK: - Json Parsing
/// Parse JSON data into a dictionary.
///
/// - Parameter json: JSON data from the request.
/// - Returns: Dicionary from parsing.
func parse(json: Data) -> [String:Any]? {
    do{
        //Converts a JSON Object to a Dictionary
        return try JSONSerialization.jsonObject(with: json, options: []) as? [String:Any]
    } catch {
        print("JSON Error \(error)")
        return nil
    }
}

/// Parse the dictionary into an array of type Result.
///
/// - Parameter dictionary: Dictionary containing the data.
/// - Returns: array of type Result.
func parseDict(dictionary: [String:Any]) -> [Result] {
    // Get the value of results into an array
    guard let array = dictionary["results"] as? [Any] else{
        return []
    }
    
    var searchResults: [Result] = []
    
    // Loop over the results array.
    for resultsDict in array{
        
        var searchResult:Result?
        
        // Make sure it is a dictionary of [String:Any]
        if let resultsDict = resultsDict as? [String:Any]{
            
            // Finds out what type is this result (Song, book, software).
            if let wrapperType = resultsDict["wrapperType"] as? String{
                switch wrapperType {
                case "track":
                    // Parse this result appropriately as a track.
                    searchResult = parseTrack(track: resultsDict)
                case "audiobook":
                    // Parse this result appropriately as an audiobook.
                    searchResult = parseAudioBook(audiobook: resultsDict)
                case "software":
                    // Parse this result appropriately as a software.
                    searchResult = parseSoftware(software: resultsDict)
                default:
                    break
                }
            }
            // Ebook don't have wrapperType but have a kind.
            else if let kind = resultsDict["kind"] as? String, kind == "ebook"{
                // Parse this result appropriately as an ebook.
                searchResult = parseEbook(ebook: resultsDict)
            }
            // Make sure the result is valid and put it in the array.
            if let result = searchResult {
                searchResults.append(result)
            }
        }
    }
    
    return searchResults
}

// MARK: - Wrapper/Kind Parsing
/// Parses a dictionary as a track and puts it in a Result.
///
/// - Parameter dictionary: Dictionary of a resulting dictionary with wrapperType track.
/// - Returns: Result containing the track information.
func parseTrack(track dictionary:[String:Any])->Result{
    let searchResult = Result()
    
    // Fill the Result with the corresponding value from the dictionary.
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}

/// Parses the dictionary as an audio book and puts it in a Result.
///
/// - Parameter dictionary: Dicitonary of a resulting dictionary with wrapperType audiobook.
/// - Returns: Result containing the audiobook information
func parseAudioBook(audiobook dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    
    // Fill the Result with the corresponding value from the dictionary.
    searchResult.name = dictionary["collectionName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["collectionViewUrl"] as! String
    //Because it has no kind field in the returned JSON
    searchResult.kind = "audiobook"
    return searchResult
}

/// Parses the dictionary as a software and puts it in a Result.
///
/// - Parameter dictionary: Dicitonary of a resulting dictionary with wrapperType software.
/// - Returns: Result containing the audiobook information
func parseSoftware(software dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    
    // Fill the Result with the corresponding value from the dictionary.
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}

/// Parses the dictionary as an ebook and puts it in a Result.
///
/// - Parameter dictionary: Dicitonary of a resulting dictionary with kind ebook.
/// - Returns: Result containing the audiobook information
func parseEbook(ebook dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    // Fill the Result with the corresponding value from the dictionary.
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}



// MARK: - TableView
extension SearchViewController: UITableViewDelegate{
    
    //When selecting a cell search the web for the storeUrl
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make sure there is data to prevent a crash.
        if Results.count > 0 {
            // Get the url from the tapped cell.
            let cellUrl = Results[indexPath.row].storeURL
            
            // The Url doesn't work on simulator but works fine in desktop safari so this shouldn't be needed.
            //var modifiedCellUrl = cellUrl.replacingOccurrences(of: "?uo=4", with: "")
            
            
            
            let url = URL(string: cellUrl)
            
            print("URL : \(String(describing: url))")
            
            // Check if any installed app can open the url.
            if UIApplication.shared.canOpenURL(url!) {
                // Open the url
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            // Open it with safari.
            else {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
        
    }
}

extension SearchViewController: UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the loading cell.
        if isDownloading {
            return 1
        }
        // Return nothing (App just started).
        else if !didSearch {
            return 0
        }
        // Return nothing found cell.
        else if Results.count == 0 {
            return 1
        }
        // Return the number of data in the array.
        else{
            return Results.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Return the loading cell.
        if isDownloading{
            let cell = tableView.dequeueReusableCell(withIdentifier: identifiers.loadingCell,for: indexPath)
            let spinner = cell.viewWithTag(42) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        // Return the nothing found cell.
        else if Results.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: identifiers.nothingFoundCell,for: indexPath)
        }
        // Return the data in the array (Search Result Cell).
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: identifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let Result = Results[indexPath.row]
            cell.configure(for: Result)
            return cell
        }
    }
}


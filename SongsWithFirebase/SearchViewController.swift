//
//  ViewController.swift
//  Apple Store
//
//  Created by Admin on 5/19/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    /*************************************************************
     *                                                           *
     *                       Outlets                             *
     *                                                           *
     *************************************************************/
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tableView:UITableView!
    
    
    /*************************************************************
     *                                                           *
     *                      Variables                            *
     *                                                           *
     *************************************************************/
    var Results: [Result] = []
    var didSearch = false
    var isDownloading = false
    var dataTask: URLSessionDataTask?
    
    
    /*************************************************************
     *                                                           *
     *                        Identifiers                        *
     *                                                           *
     *************************************************************/
    /// Nib identifiers
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    /*************************************************************
     *                                                           *
     *                     Activity LifeCycle                    *
     *                                                           *
     *************************************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        //Register My custom Nibs
        let searchResultNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell ,bundle: nil)
        tableView.register(searchResultNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell )
        
        let nothingFoundNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(nothingFoundNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        let loadingNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }
    
    /*************************************************************
     *                                                           *
     *                           Error                           *
     *                                                           *
     *************************************************************/
    func showError(){
        let alert = UIAlertController(title: "Error...", message: "There was an error with iTunes. Try again ", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


/*************************************************************
 *                                                           *
 *                Extension for searchbar                    *
 *                                                           *
 *************************************************************/
extension SearchViewController: UISearchBarDelegate{
    
//    // Attach the search bar to the top of the screen (status bar)
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .topAttached
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    /// Search with the current search bar text
    func performSearch(){
        // Search bar has text in it
        if !(searchBar.text?.isEmpty)! {
            
            // Dismiss the keyboard
            searchBar.resignFirstResponder()
            
            didSearch = true
            Results = []
            
            isDownloading=true
            tableView.reloadData()
            
            //Cancel previous requests
            dataTask?.cancel()
            
            
            let url = iTunesURL(SearchFor: searchBar.text!)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url) {
                data,response,error in
                
                // Error codes
                if let error = error as? NSError, error.code == -999 {
                    return
                }
                    // Server response
                else if let httpresponse = response as? HTTPURLResponse , httpresponse.statusCode == 200 {
                    if let data = data, let jsonDictionary = parse(json:data) {
                        
                        self.Results = parseDict(dictionary: jsonDictionary)
                        
                        DispatchQueue.main.async {
                            self.isDownloading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                }
                DispatchQueue.main.async {
                    self.didSearch = false
                    self.isDownloading = false
                    self.tableView.reloadData()
                    self.showError()
                }
            }
            dataTask?.resume()
        }
    }
    
    
}


/*************************************************************
 *                                                           *
 *                 The Networking methods                    *
 *                                                           *
 *************************************************************/
func iTunesURL(SearchFor searchText:String) -> URL{
    
    // Replace with allowed characters only
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    
    let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
    
    let url = URL(string: urlString)
    return url!
}





/*************************************************************
 *                                                           *
 *                 The JSON Parsing methods                  *
 *                                                           *
 *************************************************************/
func parse(json: Data) ->[String:Any]? {
    do{
        //Converts a JSON Object to a Dictionary
        return try JSONSerialization.jsonObject(with: json, options: []) as? [String:Any]
    } catch {
        print("JSON Error \(error)")
        return nil
    }
}

func parseDict(dictionary: [String:Any]) -> [Result] {
    // Get the value of results into an array
    guard let array = dictionary["results"] as? [Any] else{
        return []
    }
    var searchResults: [Result] = []
    
    // Loop over the
    for resultsDict in array{
        //3
        var searchResult:Result?
        if let resultsDict = resultsDict as? [String:Any]{
            //4
            if let wrapperType = resultsDict["wrapperType"] as? String{
                switch wrapperType {
                case "track":
                    searchResult = parseTrack(track: resultsDict)
                case "audiobook":
                    searchResult = parseAudioBook(audiobook: resultsDict)
                case "software":
                    searchResult = parseSoftware(software: resultsDict)
                default:
                    break
                }
            } else if let kind = resultsDict["kind"] as? String, kind == "ebook"{
                searchResult = parseEbook(ebook: resultsDict)
            }
            if let result = searchResult {
                searchResults.append(result)
            }
        }
    }
    return searchResults
}

/*************************************************************
 *                                                           *
 *                 wrapper and kind parsing                  *
 *                                                           *
 *************************************************************/
func parseTrack(track dictionary:[String:Any])->Result{
    let searchResult = Result()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}

func parseAudioBook(audiobook dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    
    searchResult.name = dictionary["collectionName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["collectionViewUrl"] as! String
    searchResult.kind = "audiobook" //Because it has no kind field in the returned JSON
    return searchResult
}

func parseSoftware(software dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}

func parseEbook(ebook dictionary: [String:Any]) -> Result{
    let searchResult = Result()
    
    searchResult.name = dictionary["trackName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
    searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["trackViewUrl"] as! String
    searchResult.kind = dictionary["kind"] as! String
    
    return searchResult
}




/*************************************************************
 *                                                           *
 *    Extensions for the protocols of UITableView            *
 *                                                           *
 *************************************************************/
extension SearchViewController: UITableViewDelegate{
    
    
    
    
}

extension SearchViewController: UITableViewDataSource{
    //When selecting a cell deselect it
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the loading cell
        if isDownloading {
            return 1
        }
            // Return nothing (App just started)
        else if !didSearch {
            return 0
        }
            // Return nothing found cell
        else if Results.count == 0 {
            return 1
        }
            // Return the number of data in the array
        else{
            return Results.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Return the loading cell
        if isDownloading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell,for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
            // Return the nothing found cell
        else if Results.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell,for: indexPath)
        }
            // Return the data in the array (Search Result Cell)
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let Result = Results[indexPath.row]
            cell.configure(for: Result)
            return cell
        }
    }
}


//
//  SearchResultCell.swift
//  Apple Store
//
//  Created by Admin on 5/22/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

   // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    // MARK: - Variables
    var downloadTask: URLSessionDownloadTask?
    


    // MARK: - Update Method
    /// Given a result sets the labels and images to the content of the data
    ///
    /// - Parameter searchResult: Data to display in the cell.
    func configure(for searchResult: Result){
        // Set the name label.
        nameLabel.text = searchResult.name
        
        // Make sure the artist name isn't empty or write unknown.
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = "Unknown"
        } else {
            // Display the kind next to the artist name
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName,kindForDisplay(searchResult.kind))
        }
        
        // Download the image with the given url.
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    /// Reformats the kind taken to be more user friendly.
    ///
    /// - Parameter kind: The kind of the result.
    /// - Returns: The kind displayed to the user.
    func kindForDisplay(_ kind: String ) -> String{
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default:
            return kind
        }
    }
    
    
    // MARK: - Cell Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // When a cell is going to be reused cancel downloading the old image.
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    
}

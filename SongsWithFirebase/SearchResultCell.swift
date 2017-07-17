//
//  SearchResultCell.swift
//  Apple Store
//
//  Created by Admin on 5/22/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    /*************************************************************
     *                                                           *
     *                         Outlets                           *
     *                                                           *
     *************************************************************/
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    /*************************************************************
     *                                                           *
     *                         Variables                         *
     *                                                           *
     *************************************************************/
    var downloadTask: URLSessionDownloadTask?
    


    func configure(for searchResult: Result){
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty{
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName,kindForDisplay(searchResult.kind))
        }
        
        //artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: searchResult.artworkSmallURL) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
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
}

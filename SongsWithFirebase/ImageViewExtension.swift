//
//  UIImageView+DownloadImage.swift
//  Apple Store
//
//  Created by Admin on 6/19/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    /// Load an image with a given url.
    ///
    /// - Parameter url: URL of the image to download.
    /// - Returns: The downloadTask being used.
    func loadImage(url:URL) -> URLSessionDownloadTask{
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url){
            // To prevent a retain cycle.
            [weak self] url,response,error in
            
            // Get the data from the url and make sure it is valid.
            if error == nil,let url = url, let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        // set the image attribute to the downloaded.
                        strongSelf.image = image
                    }
                }
            }
        }
        downloadTask.resume()
        
        return downloadTask
    }
}

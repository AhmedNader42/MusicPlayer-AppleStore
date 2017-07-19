//
//  WebViewViewController.swift
//  SongsWithFirebase
//
//  Created by Admin on 7/17/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController, WKUIDelegate {

    
    
    /*************************************************************
     *                                                           *
     *                        Variables                          *
     *                                                           *
     *************************************************************/
    var webView : WKWebView!
    var cellUrl = ""
    
    
    /*************************************************************
     *                                                           *
     *                        Activity Life Cycle                *
     *                                                           *
     *************************************************************/
    override func loadView() {
        
        // Setup the webView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
    
        webView.uiDelegate = self

        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the url
        let url = URL(string: cellUrl)
        let request = URLRequest(url: url!)
        
        // Load the request
        webView.load(request)
        
        
        

        
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed : \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("Success !")
        
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("Server Redirect")
    }
    
    

}



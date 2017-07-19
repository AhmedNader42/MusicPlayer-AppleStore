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

    
    
    
    var webView : WKWebView!
    
    var cellUrl = ""
    
    
    
    override func loadView() {
        print("CellURL : \(cellUrl)")
        let webConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        
        webView.uiDelegate = self
        
        
        
        self.view = webView
        
        print("View Loaded")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = URL(string: cellUrl)
        let request = URLRequest(url: (url?.absoluteURL)!)
        
        print("URL : \((url?.absoluteURL)!)")
        
        
        
        webView.load(request)
//        if UIApplication.shared.canOpenURL(url!) {
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        }
        
        print("URL WebView : \(webView.url)")
        
        
        print("isLoading : \(webView.isLoading)")
        
        
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



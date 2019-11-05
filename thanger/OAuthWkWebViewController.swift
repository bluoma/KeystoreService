//
//  OAuthWkWebViewController.swift
//  thanger
//
//  Created by Bill on 11/3/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import WebKit

protocol OAuthWkWebViewControllerDelegate: AnyObject {
    
    func webViewController(_ viewController: OAuthWkWebViewController, userDidFinishManually sender: Any)
    func webViewController(_ viewController: OAuthWkWebViewController, didEncounterError error: Error?)
    func webViewController(_ viewController: OAuthWkWebViewController, userDidAuthorizeWith authCode: String)
}

class OAuthWkWebViewController: UIViewController {


    @IBOutlet weak var webView: WKWebView!
    weak var delegate: OAuthWkWebViewControllerDelegate?
    var urlRequest: URLRequest?
    var requestLoaded = false
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if requestLoaded {
            return
        }
        
        guard let urlRequest = urlRequest else {
            let error = ServiceError(type: .invalidRequest, code: -2, msg: "bad urlRequest")
            delegate?.webViewController(self, didEncounterError: error)
            return
        }
        webView.navigationDelegate = self
        webView.load(urlRequest)
        requestLoaded = true
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dlog("")
        delegate?.webViewController(self, userDidFinishManually: sender)
    }
    
}


extension OAuthWkWebViewController: WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {

        guard let url = navigationAction.request.url else { return }
        dlog("\nurl: \(url)")
        guard let host = url.host else { return }
        let path = url.path
        
        guard let redirectUrl = URL(string: coinbaseOAuth2RedirectUri) else { return }
        guard let redirHost = redirectUrl.host else { return }
        let redirPath = redirectUrl.path
        
        if host == redirHost && path == redirPath {
            
            guard let query = url.query else { return }
            //param name is 'code', also if 'state' param was passed with initial load, it is returned
        //https://www.example.com/callback?code=ee658617aa01327c79097ade6c1366d9367f1fcbbb764071ae32c95a6cbe5151&state=C25425CA-29F4-4703-8D0A-D87694565033
            
            var queryDict: [String: String] = [:]
            
            let keyValPairs = query.split(separator: "&")
            for keyVal in keyValPairs {
                let keyAndValPair = keyVal.split(separator: "=")
                if keyAndValPair.count == 2 {
                    let key = String(keyAndValPair[0])
                    let val = String(keyAndValPair[1])
                    queryDict[key] = val
                }
            }
            dlog("auth queryDict: \(queryDict)")
            if let code = queryDict["code"] {
                decisionHandler(.cancel)
                
                DispatchQueue.main.async {
                    self.delegate?.webViewController(self, userDidAuthorizeWith: code)
                }
                return
            }
        }
        
              
        switch navigationAction.navigationType {
            
        case .linkActivated:
            dlog("navType linkActivated: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
            
        case .backForward:
            dlog("navType backForward: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
            
        case .formResubmitted:
            dlog("navType formResubmitted: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
            
        case .formSubmitted:
            dlog("navType formSubmitted: \(navigationAction.navigationType.rawValue)")
             decisionHandler(.allow)
            
        case .reload:
            dlog("navType reload: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
            
        case .other:
            dlog("navType other: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
            
        default:
            dlog("navType default: \(navigationAction.navigationType.rawValue)")
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        dlog("navigation: \(String(describing: navigation))")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dlog("error: \(error)")
        delegate?.webViewController(self, didEncounterError: error)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dlog("navigation: \(String(describing: navigation))")

    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dlog("navigation: \(String(describing: navigation)), error: \(error)")
        delegate?.webViewController(self, didEncounterError: error)

    }
    
}

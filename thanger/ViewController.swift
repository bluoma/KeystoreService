//
//  ViewController.swift
//  thanger
//
//  Created by Bill on 10/28/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    let userAccountService = UserAccountService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.showWkWebView()
    }
    
    func showWkWebView() {
        
        guard let wkRequest = userAccountService.createAuthorizationCodeRequest(),
            let url = wkRequest.url else {
            dlog("error getting request")
            return
        }
        dlog("url: \n\(url)")
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OAuthWkWebViewController") as? OAuthWkWebViewController else {
            
            dlog("error creating wkwebview controller")
            return
        }
        
        vc.urlRequest = wkRequest
        vc.delegate = self
        //vc.modalTransitionStyle = .crossDissolve
        //vc.modalPresentationStyle = .overFullScreen
        
        let modalNav = UINavigationController(rootViewController: vc)
        modalNav.setNavigationBarHidden(false, animated: false)
        modalNav.modalTransitionStyle = .crossDissolve
        modalNav.modalPresentationStyle = .overFullScreen
        self.present(modalNav, animated: true, completion: nil)
    }
    
    func showSafari() {
        
        guard let sfRequest = userAccountService.createAuthorizationCodeRequest(),
            let url = sfRequest.url else {
            dlog("error getting sfrequest")
            return
        }
        dlog("url: \n\(url)")
        
        let safari = SFSafariViewController(url: url)
        //let _ = safari.view  //hack around empty screen if sfvc is not root of nav
        safari.delegate = self
        safari.modalTransitionStyle = .crossDissolve
        safari.modalPresentationStyle = .overFullScreen
        let sfRegisterModalNav = UINavigationController(rootViewController: safari)
        sfRegisterModalNav.setNavigationBarHidden(true, animated: false)
        self.present(sfRegisterModalNav, animated: true, completion: nil)
    }
    
}

extension ViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dlog("")
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        dlog("success: \(didLoadSuccessfully)")

    }

    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        dlog("redir: \(URL)")

    }
}

extension ViewController: OAuthWkWebViewControllerDelegate{
    
    func webViewController(_ viewController: OAuthWkWebViewController, userDidFinishManually sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewController(_ viewController: OAuthWkWebViewController, didEncounterError error: Error?) {
        //self.dismiss(animated: true, completion: nil)
        dlog("error: \(String(describing: error))")
    }
    
    func webViewController(_ viewController: OAuthWkWebViewController, userDidAuthorizeWith authCode: String) {
        viewController.webView.stopLoading()
        self.dismiss(animated: true, completion: nil)
        dlog("code: \(String(describing: authCode))")
        
        userAccountService.createAuthToken(withAuthCode: authCode) { (authToken: Secret?, error: Error?) in
            
            if let error = error {
                dlog("error: \(error)")
            }
            else {
                dlog("authToken: \(String(describing: authToken))")
            }
        }
    }
}



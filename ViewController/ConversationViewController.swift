//
//  ViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if !isLoggedIn{
            
            let vc = LoginViewController()
            vc.title = "Log in"
            
            let nav = UINavigationController(rootViewController: vc)
            
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: true, completion: nil)
            
        }
    }


    
    
    
}


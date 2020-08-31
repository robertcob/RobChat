//
//  ViewController.swift
//  Rob_Chat
//
//  Created by Robert O'Brien on 14/08/2020.
//  Copyright © 2020 Robert O'Brien. All rights reserved.
//

import UIKit
import FirebaseAuth
class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .red
        
//        DatabaseManager.shared.test()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        validateAuth()

        
    }
    
    // checking user state if logged in or not
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }


}


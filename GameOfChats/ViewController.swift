//
//  ViewController.swift
//  GameOfChats
//
//  Created by admin on 7/11/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
    }
    func handleLogout(){
        
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
        
    }

}


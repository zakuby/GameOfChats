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


class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "note (1)")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessages) )
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        
        
        CheckIfUserIsLoggedIn()
        
    }
    
    func handleNewMessages(){
        
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    
    func CheckIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value , with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                }
                
                
            }, withCancel: { (nil) in
            
            })
            
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


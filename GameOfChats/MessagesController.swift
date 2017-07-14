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
            LoginsetNavBarTitle()
        }
        
    }
    
    func LoginsetNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        self.navigationItem.title = ""
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value , with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
                
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User){
        self.navigationItem.title = user.name
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)
            
        
            
        }
        
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        containerView.addSubview(profileImageView)
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        containerView.addSubview(nameLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
    }
    
    func handleLogout(){
        
        do{
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
        
    }

}


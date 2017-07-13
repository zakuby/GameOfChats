//
//  LoginControllerHandlers.swift
//  GameOfChats
//
//  Created by admin on 7/13/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        present(picker, animated: true, completion: nil)
    }
}

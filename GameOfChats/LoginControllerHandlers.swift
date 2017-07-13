//
//  LoginControllerHandlers.swift
//  GameOfChats
//
//  Created by admin on 7/13/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text  else {
            print("Form is not valid")
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { ( user, errMsg ) in
            
            if errMsg != nil {
                print(errMsg!)
                return
            }
            guard let uid = user?.uid else{
                return
            }
            let storageRef = Storage.storage().reference().child("myImage.png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, errMsg) in
                    if errMsg != nil{
                        print(errMsg!)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.RegisterUserToDatabase(uid: uid, values: values)
                    }
                    
                    
                })
            }
            
        })
    }
    
    func RegisterUserToDatabase(uid: String, values: [String: AnyObject]){
        
        let ref = Database.database().reference(fromURL: "https://chatapp-c933c.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            
            if err != nil {
                print(err!)
                return
            }else{
                print("Saved user successfully into Firebase")
                self.nameTextField.text = ""
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
        })
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        dismiss(animated: true, completion: nil)
    }
}

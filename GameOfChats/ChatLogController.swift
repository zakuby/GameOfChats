//
//  ChatLogController.swift
//  GameOfChats
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate,UICollectionViewDelegateFlowLayout {
    
    var user: User?{
        didSet {
            navigationItem.title = user?.name
            observerMessages()
        }
    }
    
    var messages = [Messages]()
    
    func observerMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        let userMessageRef = Database.database().reference().child("user-messages").child(uid)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageID)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else{
                    return
                }
                
                let message = Messages()
                message.setValuesForKeys(dictionary)
                if message.chatPartnerID() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    let cellId = "cellId"
    
    let inputTextField: UITextField = {
        let enterMessage = UITextField()
        enterMessage.placeholder = "Enter a message...."
        enterMessage.translatesAutoresizingMaskIntoConstraints = false
        enterMessage.delegate = self as? UITextFieldDelegate
        return enterMessage
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
    }
    func setupInputComponents(){
        let containerView = UIView()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        
        let sendButton = UIButton()
        sendButton.backgroundColor = UIColor.white
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(UIColor.black, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(sendButton)
        containerView.addSubview(separatorView)
        containerView.addSubview(inputTextField)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -12).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }
    
    func handleSendMessage(){
        
        if inputTextField.text != nil || inputTextField.text != ""{
            let text = inputTextField.text
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toID = user?.id
            let fromID = Auth.auth().currentUser?.uid
            let timestamp = Int(NSDate().timeIntervalSince1970)
            let values:[String: Any] = ["text":text!, "toId": toID!, "fromID": fromID!, "timestamp": timestamp]
            
            childRef.updateChildValues(values) { (errorMsg, ref) in
                if errorMsg != nil {
                    print(errorMsg!)
                    return
                }
                
                let userMessageRef = Database.database().reference().child("user-messages").child(fromID!)
                
                let messageID = childRef.key
                userMessageRef.updateChildValues([messageID: 1])
                
                let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toID!)
                
                recipientUserMessageRef.updateChildValues([messageID: 1])
            }
            inputTextField.text = nil
        }
            
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.row].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
        
    }
    private func estimatedFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        
        let bubbleViewWidth = estimatedFrameForText(text: message.text!).width + 32
        
        
        
        if Auth.auth().currentUser?.uid == message.fromID{
            cell.bubbleView.backgroundColor = UIColor.blue
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }else{
            cell.bubbleView.backgroundColor = UIColor.gray
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
        cell.bubbleViewWidthAnchor?.constant = bubbleViewWidth
        cell.textView.text = message.text
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

//
//  UserCell.swift
//  GameOfChats
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Messages?{
        didSet{
            setupNameAndProfileImage()
            if let seconds = message?.timestamp?.doubleValue {
                let timeStampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                timeLabel.text = dateFormatter.string(from: timeStampDate)
            }
            detailTextLabel?.text = message?.text
        }
    }
    
    
    private func setupNameAndProfileImage(){
        if let toID = message?.chatPartnerID(){
            let ref = Database.database().reference().child("users").child(toID)
            let user = User()
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    user.setValuesForKeys(dictionary)
                    self.textLabel?.text = user.name
                    if let profileImageUrl = user.profileImageUrl {
                        self.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
                    }
                }
            })
        }
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = UIColor.colo
    }
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultProfileImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
       let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: 12)
        tl.textColor = UIColor.darkGray
        tl.translatesAutoresizingMaskIntoConstraints = false
        return tl
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: -32).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.widthAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

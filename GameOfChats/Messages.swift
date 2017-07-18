//
//  Messages.swift
//  GameOfChats
//
//  Created by admin on 7/17/17.
//  Copyright © 2017 indosystem. All rights reserved.
//

import UIKit
import Firebase

class Messages:NSObject {
    var fromID: String?
    var toId: String?
    var timestamp: NSNumber?
    var text: String?
    
    
    func chatPartnerID() -> String?{
        return fromID == Auth.auth().currentUser?.uid ? toId : fromID
    }
    
}

//
//  ConversationModel.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-04.
//

import Foundation

struct ConversationModel{
    
    var chattingWithName : String
    
    var latestMessage : LatestMessage
    
    var chattingWithEmail : String
    
    var convoID : String
    
    
    
}

struct LatestMessage{
    
    var date : String
    var isRead : Bool
    var message : String
}


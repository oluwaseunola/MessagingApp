//
//  ChatViewModel.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-05.
//

import Foundation
import MessageKit
import CoreLocation

struct Message : MessageType {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    var isRead : Bool
    
    
}

extension MessageKind {
    
    var description : String{
        switch self{
            
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"

        case .video(_):
            return "video"

        case .location(_):
            return "location"

        case .emoji(_):
            return "emoji"

        case .audio(_):
            return "audio"

        case .contact(_):
            return "contact"

        case .linkPreview(_):
            return "linkPreview"

        case .custom(_):
            return "custom"

        }
    }
    
}

struct Sender: SenderType{
    
    var senderId: String
    
    var displayName: String
    
    var photoURL : String
    
    
    
}

struct Media : MediaItem {
   
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    
    
    
    
}

struct Location: LocationItem{
    
    var location : CLLocation
    var size : CGSize
}

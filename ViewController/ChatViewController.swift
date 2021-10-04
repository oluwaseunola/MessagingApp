//
//  ChatViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-28.
//

import UIKit
import MessageKit

struct Message : MessageType {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    
    
    
}

struct Sender: SenderType{
    
    var senderId: String
    
    var displayName: String
    
    var photoURL : String
    
    
    
}

class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    
    private var sender = Sender(senderId: "1", displayName: "bobby", photoURL: "")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        
        messages.append(Message(sender: sender, messageId: "01", sentDate: Date(), kind: .text("What's good")))
    }
    


}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
   
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    
}

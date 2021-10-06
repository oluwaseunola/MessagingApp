//
//  ChatViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-28.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    static let dateFormatter : DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        
        
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var sender : Sender? {
        guard let safeEmail = UserDefaults.standard.string(forKey: "userEmail") else {return nil}
        
       return Sender(senderId: safeEmail, displayName: "me", photoURL: "")
        
    }
    
    public var chattingWithEmail: String
    public var chattingWithName : String
    private var convoID : String?
    

    private var isNewConvo : Bool = true
    
    init(chattingWithEmail: String, chattingWithName: String, convoID: String?) {
        self.chattingWithEmail = chattingWithEmail
        self.chattingWithName = chattingWithName
        self.convoID = convoID
        super.init(nibName: nil, bundle: nil)
        
        if let convoID = convoID {
            listenForMessages(id: convoID)
        }
        

        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
      
    }
    
    
    public func listenForMessages(id: String){
        
        DatabaseManager.shared.getAllMessages(with: id) { [weak self] allMessages in
            
            
            self?.messages = allMessages
            
            DispatchQueue.main.async {
                
                self?.messagesCollectionView.reloadDataAndKeepOffset()
            }
            
        }
        
    }


}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate{
   
    func currentSender() -> SenderType {
        if let sender = self.sender {
            return sender
        }
        
        fatalError("Self sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let safeSender = self.sender else{return}
         
        if isNewConvo {
            
            
            let message = Message(sender: safeSender , messageId: createMessageID(), sentDate: Date() , kind: .text(text), isRead: false)
            
            DatabaseManager.shared.createNewConvo(chattingWithEmail: chattingWithEmail, chattingWithName: chattingWithName, firstMessage: message) { success in
                
                if success{
                    print("Successfully added new convo")
                } else{
                    
                    print("error creating new convo in firebase")
                }
                
            }
            
        }else{
            
//            append
        }
        
    }
    
    private func createMessageID()-> String{
        
        guard let safeEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return ""}
        
        
        let safeChattingWithEmail = chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        let messageID = "\(safeEmail)_\(ChatViewController.dateFormatter.string(from: Date()))_\(safeChattingWithEmail)"
        
        return messageID
        
    }
    
    
    
    
}

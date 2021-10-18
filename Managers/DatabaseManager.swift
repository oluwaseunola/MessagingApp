//
//  DatabaseManager.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-27.
//

import Foundation
import FirebaseDatabase
import MessageKit
import CoreLocation

class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private init() {
        
    }
    
    let databse = Database.database()
    
    /// Checks if new user already exists in the system

    func validateNewUser(email: String, completion: @escaping (Bool)-> Void){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        print("this is your safe email \(safeEmail)")
        
        databse.reference().child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard let _ = snapshot.value as? [String:Any] else{
                
                completion(false)
                return
            }
            
            completion(true)
            
        }
        
    }
    
    /// Saves new user model to database

    func saveUser(user: UserModel){
        
        let safeEmail = user.email.replacingOccurrences(of: ".", with: "_")
        
        databse.reference().child("users").child(safeEmail).setValue(["userFirstName": user.firstName, "userLastName": user.lastName, "userEmail": user.email])
        
    }
    
    /// Returns a list of users

    func fetchAllUsers(completion: @escaping ([[String:Any]])->Void){
        
        let ref = databse.reference().child("users")
        
        ref.getData { error, snapshot in
            
            
            if error == nil{
                
                guard let users = snapshot.value as? NSDictionary else{return}
                let userList = users.compactMap({$0.value as? NSDictionary})
                print(userList)
                
                
                let userData = userList.compactMap({$0 as? [String: Any]})
                
                completion(userData)
                
                
                
                
            }else{
                
                print(error?.localizedDescription)
            }
            
            
            
        }
        
    }
    
    /// Creates a new conversation

    
    public func createNewConvo( chattingWithEmail: String, chattingWithName: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        
        guard let safeCurrentEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return}
        guard let currentName = UserDefaults.standard.string(forKey: "userName") else {return}
        let safeChattingWithEmail = chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        let ref = databse.reference().child("users").child(safeCurrentEmail)
        let ref2 = databse.reference().child("users").child(safeChattingWithEmail)
        
        let convoID = "conversation_\(firstMessage.messageId)"
        
        var messageText = ""
        
        switch firstMessage.kind {
            
        case .text(let text):
            messageText = text
        case .attributedText(_):
            break
        case .photo(_):
            break
            
        case .video(_):
            break
            
        case .location(let location):
            
            messageText = "\(location.location.coordinate.longitude),\( location.location.coordinate.latitude)"
            
        case .emoji(_):
            break
            
        case .audio(_):
            break
            
        case .contact(_):
            break
            
        case .linkPreview(_):
            break
            
        case .custom(_):
            break
            
        }
        
        ref.getData {  error, snapshot in
            
            
            guard var user = snapshot.value as? [String : Any] else {return}
            
            
            let newConvo : [String:Any] = [
                
                "chattingWIthName": chattingWithName,
                "chattingWithEmail": chattingWithEmail,
                "convoID": convoID,
                "latestMessage": [
                    "date": ChatViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "isRead": false,
                    "message": messageText
                ]
            ]
            
            let recipientConvo : [String:Any] = [
                
                "chattingWIthName": currentName,
                "chattingWithEmail": safeCurrentEmail,
                "convoID": convoID,
                "latestMessage": [
                    "date": ChatViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "isRead": false,
                    "message": messageText
                ]
            ]
            
            //            Creates new, or adds onto convo for person we are chatting with
            
            ref2.child("conversation").observeSingleEvent(of: .value) { recipientSnapShot in
                
                
                if var conversation = snapshot.value as? [[String:Any]] {
                    
                    conversation.append(recipientConvo)
                    
                    ref2.child("conversation").setValue(conversation) { error, _ in
                        
                        if error == nil{
                            completion(true)
                            print("successfully added onto existing convo")
                        }else{
                            completion(false)
                            print("could not add onto existing convo")
                            
                        }
                        
                    }
                    
                    
                    
                }else{
                    
                    //                create new convo
                    
                    let recipientConvoArray = [
                        recipientConvo
                    ]
                    
                    
                    ref2.child("conversation").setValue(recipientConvoArray) { error, _ in
                        if error == nil{
                            completion(true)
                            print("successfully added conversation to firebase")
                            
                        }else{
                            completion(false)
                            
                            print("there was an error adding your conversation to firebase")
                            
                        }
                    }
                }
                
                
            }
            
            //            current user add convo
            
            
            
            if var conversation = user["conversation"] as? [[String:Any]] {
                
                
                conversation.append(newConvo)
                user["conversation"] = conversation
                
                ref.setValue(user) { [weak self] error, _ in
                    
                    if error == nil{
                        self?.addConvoToMainBranch(conversationID: convoID, chattingWithName: chattingWithName, latestMessage: firstMessage, completion: completion)
                        
                        print("successfully added onto existing convo")
                    }else{
                        completion(false)
                        print("could not add onto existing convo")
                        
                    }
                    
                }
                
                
                
            }else{
                //                create new convo
                
                user["conversation"] = [
                    newConvo
                ]
                
                ref.setValue(user) { [weak self] error, _ in
                    if error == nil{
                        
                        print("successfully added conversation to firebase")
                        
                        self?.addConvoToMainBranch(conversationID: convoID, chattingWithName: chattingWithName, latestMessage: firstMessage, completion: completion)
                    }else{
                        
                        print("there was an error adding your conversation to firebase")
                        
                    }
                }
            }
           
            
        }
        
        
        
    }
    
    /// Adds conversation onto the main branch of our database to make access to messages, via a conversation ID, much easier.

    
    private func addConvoToMainBranch(conversationID: String, chattingWithName: String, latestMessage:Message, completion: @escaping (Bool)->Void){
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "userEmail") else{return}
        
        
        var messageText = ""
        
        switch latestMessage.kind {
            
        case .text(let text):
            messageText = text
        case .attributedText(_):
            break
        case .photo(_):
            break
            
        case .video(_):
            break
            
        case .location(_):
            break
            
        case .emoji(_):
            break
            
        case .audio(_):
            break
            
        case .contact(_):
            break
            
        case .linkPreview(_):
            break
            
        case .custom(_):
            break
            
        }
        
        let message : [String : Any] = [
            "id": latestMessage.messageId,
            "type": latestMessage.kind.description,
            "content": messageText,
            "date": ChatViewController.dateFormatter.string(from: latestMessage.sentDate),
            "senderEmail": currentUserEmail,
            "chattingWith":chattingWithName,
            "isRead": false
            
            
            
        ]
        
        let value : [String:Any] = [
            "messages": [message]
        ]
        
        let mainRef = databse.reference().child(conversationID)
        
        
        
        
        mainRef.setValue(value) { error, _ in
            
            if error == nil{
                completion(true)
                print("successfully saved to firebase")
            }else{
                completion(false)
                print("error saving your converation to firebase")
            }
            
        }
        
        
        
        
        
    }
    
    /// Fetches all conversations for our current user to display

    
    public func getAllConvos(with: String, completion: @escaping (Result<[ConversationModel], Error>)-> Void){
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return}
        
        
        let ref = databse.reference().child("users").child(currentEmail).child("conversation")
        
        ref.observe(.value) { snapshot in
            
            guard let snapshotData = snapshot.value as? [[String:Any]] else{completion(.failure(DatabaseError.failedToFetch))
                return}
            
            let conversation : [ConversationModel] = snapshotData.compactMap({ dictionary in
                
                guard let chattingWithName = dictionary["chattingWIthName"] as? String,let chattingWithEmail = dictionary["chattingWithEmail"] as? String, let convoID = dictionary["convoID"] as? String, let latestMessage = dictionary["latestMessage"] as? [String:Any], let date = latestMessage["date"] as? String, let isRead = latestMessage["isRead"] as? Bool, let message = latestMessage["message"] as? String else{return nil}
                
                
                let latestMessageObject = LatestMessage(date: date, isRead: isRead, message: message )
                
                let conversationModel = ConversationModel(chattingWithName: chattingWithName, latestMessage: latestMessageObject, chattingWithEmail: chattingWithEmail, convoID: convoID)
                
                return conversationModel
            })
            
            completion(.success(conversation))
            
            
        }
        
        
    }
    
    /// Fetches all messages via a conversation ID and returns an array of messages for the user to display.
    
    public func getAllMessages(with id: String, completion: @escaping ([Message])-> Void){
        
        let ref = databse.reference().child(id).child("messages")
        ref.observe(.value) {  snapshot in
            
            guard let snapshotValue = snapshot.value as? [[String:Any]] else {return}
            
            let kindValue : MessageKind = .text("Placeholder")
            
            let messages : [Message] = snapshotValue.compactMap({ [weak self] dictionary in
                
                guard let chattingWith = dictionary["chattingWith"] as? String,
                      let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String ,
                      let messageID = dictionary["id"] as? String ,
                      let isRead = dictionary["isRead"] as? Bool ,
                      let senderEmail = dictionary["senderEmail"] as? String ,
                      let type = dictionary["type"] as? String,
                      let formattedDate = ChatViewController.dateFormatter.date(from: date) else {return nil}
                
                
                //                switch on the type, assign it to kind value and  return it.
                
                guard let messageKind = self?.switchOnType(placeHolder: kindValue, messageKind: type, content: content) else {return nil}
                
                
                let senderObject = Sender(senderId: senderEmail, displayName: chattingWith, photoURL: "")
                
                let messageModel = Message(sender: senderObject, messageId: messageID, sentDate: formattedDate, kind: messageKind, isRead: isRead)
                
                return messageModel
            })
            
            
            completion(messages)
            
            
        }
        
        
        
        
        
    }
    /// Update latest message on firebase for current user and person we are chatting with

    public func sendMessageToConvof(with conversationID: String, chattingWithEmail: String,chattingWithName: String, message: Message, completion: @escaping (Bool)-> Void){
        
        let ref = databse.reference().child(conversationID).child("messages")
        
        var messageText = ""
        
        switch message.kind {
            
        case .text(let text):
            messageText = text
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            guard let urlString = mediaItem.url?.absoluteString else {return}
            
            messageText = urlString
            
        case .video(let video):
            guard let videoURL = video.url else{return}
            
            messageText = videoURL.absoluteString
            
        case .location(let location):
            
            messageText = "\(location.location.coordinate.longitude),\( location.location.coordinate.latitude)"
            
        case .emoji(_):
            break
            
        case .audio(_):
            break
            
        case .contact(_):
            break
            
        case .linkPreview(_):
            break
            
        case .custom(_):
            break
            
        }
        
        
        guard let currentUserEmail = UserDefaults.standard.string(forKey: "userEmail") else{return}
        
        
        
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            guard var value = snapshot.value as? [[String : Any?]] else{return}
            
            
            
            let newMessage : [String : Any] = [
                "id": message.messageId,
                "type": message.kind.description,
                "content": messageText,
                "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                "senderEmail": currentUserEmail,
                "chattingWith":chattingWithName,
                "isRead": false
                
                
                
            ]
            
            value.append(newMessage)
            
            ref.setValue(value) { error, _ in
                
                if error == nil {
                    
                    
                    
                }else{
                    
                    print("error appending messages in database call")
                    
                }
                
                
            }
            
            
        }
        
        //MARK: - update latest message for current user
        
        let safeEmail = currentUserEmail.replacingOccurrences(of: ".", with: "_")
        let ref2 =  self.databse.reference().child("users").child(safeEmail).child("conversation")
        
        var finalConversation : [[String:Any]] = []
        
        
        ref2.observeSingleEvent(of: .value) { [weak self] datasnapshot in
            
            
            
            if var conversations = datasnapshot.value as? [[String:Any]] {
                
                let updatedValue : [String : Any] = [
                    "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                    "isRead": false,
                    "message": messageText
                ]
                var position = 0
                var updatedConversation : [String:Any]?
                for conversation in conversations{
                    
                    if conversation["convoID"] as? String == conversationID{
                        
                        updatedConversation = conversation
                        updatedConversation?["latestMessage"] = updatedValue
                        
                        break
                    }
                    position += 1
                    
                }
                
                if let updatedConvo = updatedConversation {
                    
                    conversations[position] = updatedConvo
                    finalConversation = conversations
                    
                }else{
                    
                    let newConvo : [String:Any] = [
                        
                        "chattingWIthName": chattingWithName,
                        "chattingWithEmail": chattingWithEmail,
                        "convoID": conversationID,
                        "latestMessage": [
                            "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                            "isRead": false,
                            "message": messageText
                        ]
                    ]
                    
                    conversations.append(newConvo)
                    finalConversation = conversations
                }
                
                
                
            }else{
                
                let newConvo : [String:Any] = [
                    
                    "chattingWIthName": chattingWithName,
                    "chattingWithEmail": chattingWithEmail,
                    "convoID": conversationID,
                    "latestMessage": [
                        "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                        "isRead": false,
                        "message": messageText
                    ]
                ]
                
                finalConversation = [newConvo]
            }
            
            self?.databse.reference().child("users").child(safeEmail).child("conversation").setValue(finalConversation) { error, _ in
                
                if error == nil{
                    completion(true)
                    print("success appending messages in database call and updated latest message")
                }else{
                    
                    completion(false)
                    print("error appending messages in database call and could not update latest message")
                }
            }
        }
        
        //MARK: - update latest message for user we're talking to
        
        let safeChattingWithEmail = chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        
        self.databse.reference().child("users").child(safeChattingWithEmail).child("conversation").observeSingleEvent(of: .value) { [weak self] datasnapshot in
            
            var finalRecipientConversation : [[String:Any]] = []
            
            
            if var conversations = datasnapshot.value as? [[String:Any]] {
                
                var position = 0
                var updatedConversation : [String:Any] = [:]
                for conversation in conversations{
                    
                    if var updatedConvo = conversation as? [String:Any], updatedConvo["convoID"] as? String == conversationID{
                        
                        updatedConvo["latestMessage"] = [
                            "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                            "isRead": false,
                            "message": messageText
                        ]
                        
                        updatedConversation = updatedConvo
                        
                        break
                    }
                    position += 1
                    
                    
                }
                
                conversations[position] = updatedConversation
                finalRecipientConversation = conversations
                
            }else{
                
                let newRecipientConvo : [String:Any] = [
                    
                    "chattingWIthName": chattingWithName,
                    "chattingWithEmail": safeEmail,
                    "convoID": conversationID,
                    "latestMessage": [
                        "date": ChatViewController.dateFormatter.string(from: message.sentDate),
                        "isRead": false,
                        "message": messageText
                    ]
                ]
                
                finalRecipientConversation = [newRecipientConvo]
                
            }
            
            
            
            
            
            self?.databse.reference().child("users").child(safeChattingWithEmail).child("conversation").setValue(finalRecipientConversation) { error, _ in
                
                if error == nil{
                    completion(true)
                    print("success appending messages to chattingWith in database call and updated latest message")
                }else{
                    
                    completion(false)
                    print("error appending messages in database call and could not update latest message")
                }
            }
            
            
            
        }
        
        
    }
    
    /// Switches on the type description of a message and returns message kind

    
    private func switchOnType(placeHolder: MessageKind, messageKind: String, content: String ) -> MessageKind?{
        
        switch messageKind{
            
        case "text":
            var holder = placeHolder
            
            holder = MessageKind.text(content)
            
            return holder
        case "attributedText":
            break
            
        case "photo":
            
            guard let url = URL(string: content) else {return nil}
            guard let placeHolderImage = UIImage(systemName: "photo")?.withBackground(color: .white) else{return nil}
            
            let mediaObject = Media(url: url, image: nil, placeholderImage: placeHolderImage, size: CGSize(width: 200, height: 200))
            
            return MessageKind.photo(mediaObject)
        case "video":
            
            guard let url = URL(string: content) else {return nil}
            guard let placeHolderImage = UIImage(systemName: "video")?.withBackground(color: .white) else{return nil}
            
            let mediaObject = Media(url: url, image: nil, placeholderImage: placeHolderImage, size: CGSize(width: 200, height: 200))
            
            return MessageKind.photo(mediaObject)
        case "location":
            
            let components = content.components(separatedBy: ",")
            
            guard let longitude = Double(components[0]), let latitude = Double(components [1]) else {
                print("no longitude")
                return nil}
            
            let locationObject = Location(location: CLLocation(latitude:latitude , longitude: longitude) , size: CGSize(width: 200, height: 200))
            
            return MessageKind.location(locationObject)
            
        case "emoji":
            
            break
        case "audio":
            
            break
        case "contact":
            break
        case "linkPreview":
            break
        case "custom":
            break
        default:
            break
        }
        return nil
    }
    /// Deletes convos from firebase
    public func deleteConversation(id: String, completion: @escaping (Bool)->Void){
        
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else{return}
        
        let ref =  databse.reference().child("users").child(userEmail).child("conversation")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            guard var value = snapshot.value as? [[String : Any]] else {return}
            
            
            
            var indexPath = 0
            
            for conversation in value {
                
                if let convoID = conversation["convoID"] as? String, convoID == id {
                    break
                    
                }
                
                indexPath += 1
                
            }
            
            value.remove(at: indexPath)
            
            
            
            ref.setValue(value) { error, _ in
                if error == nil{
                    completion(true)
                    print("successfully deleted convo")
                    
                }
                else{
                    completion(false)
                    print("could not delete convo")
                    
                }
            }
            
        }
        
        
    }
    
    /// checks if a conversation already exits before creating a brand new one incase it was deleted.

    
    public func conversationExists(chattingWithEmail: String, completion: @escaping (Result<String, Error>)-> Void){
        
        guard let email = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else{return}
        let safeChattingWithEmail = chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        
        databse.reference().child("users").child(safeChattingWithEmail).child("conversation").observeSingleEvent(of: .value) { snapshot in
            
            if let conversations = snapshot.value as? [[String:Any]] {
                
                var convoID = ""
                
                for conversation in conversations {
                    
                    if conversation["chattingWithEmail"]as? String == email, let recoveredConvoID = conversation["convoID"] as? String {
                        convoID = recoveredConvoID
                        print("this is your convo ID \(convoID)")
                        completion(.success(convoID))
                        
                    }
                    else{
                        completion(.failure(DatabaseError.failedToFetch))}
                    return
                    
                }
                
                
            }
            
            completion(.failure(DatabaseError.failedToFetch))
            
        }
        
        
    }
    
    
}

struct DatabaseError{
    
    static let failedToFetch = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "could not fetch"])
    
}





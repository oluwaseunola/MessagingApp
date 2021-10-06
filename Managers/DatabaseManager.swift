//
//  DatabaseManager.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-27.
//

import Foundation
import FirebaseDatabase

struct DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private init() {
        
    }
    
    let databse = Database.database()
    
    func validateNewUser(email: String, completion: @escaping (Bool)-> Void){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        databse.reference().child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard let _ = snapshot.value as? String else{
                
                completion(false)
                return
            }
            
            completion(true)
            
        }
        
    }
    
    func saveUser(user: UserModel){
        
        let safeEmail = user.email.replacingOccurrences(of: ".", with: "_")
        
        databse.reference().child("users").child(safeEmail).setValue(["userFirstName": user.firstName, "userLastName": user.lastName, "userEmail": user.email])
        
        
        
    }
    
    
    func fetchAllUsers(completion: @escaping ([[String:String]])->Void){
        
        let ref = databse.reference().child("users")
        
        ref.getData { error, snapshot in
            
            
            if error == nil{
                
                guard let users = snapshot.value as? NSDictionary else{return}
                
                let userList = users.compactMap({$0.value as? NSDictionary})
                
                
                let userData = userList.compactMap({$0 as? [String: String]})
                
                completion(userData)
                
                
                
                
            }else{
                
                print(error?.localizedDescription)
            }
            
            
            
        }
        
    }
    //    Create new convo
    public func createNewConvo(chattingWithEmail: String, chattingWithName: String, firstMessage: Message, completion: @escaping (Bool)-> Void){
        
        guard let safeCurrentEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return}
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
                
                "chattingWIthName": "self",
                "chattingWithEmail": safeCurrentEmail,
                "convoID": convoID,
                "latestMessage": [
                    "date": ChatViewController.dateFormatter.string(from: firstMessage.sentDate),
                    "isRead": false,
                    "message": messageText
                ]
            ]
            
            //            do the same for the user we are talking to

            ref2.child("conversation").observeSingleEvent(of: .value) { recipientSnapShot in
    
                
                if var conversation = snapshot.value as? [[String:Any]] {
                    
                    conversation.append(recipientConvo)
                    
                    ref2.child("conversation").setValue(conversation) { error, _ in
                        
                        if error == nil{
                          
                            print("successfully added onto existing convo")
                        }else{
                            print("could not add onto existing convo")
                            
                        }
                        
                    }
                    
                    
                    
                }else{
                    //                create new convo
                    
                    ref2.child("conversation").setValue(recipientConvo) { error, _ in
                        if error == nil{
                            
                            print("successfully added conversation to firebase")
                        
                        }else{
                            
                            print("there was an error adding your conversation to firebase")
                            
                        }
                    }
                }
                
                
            }
            
            //            current user add convo

            
            
            if var conversation = user["conversation"] as? [[String:Any]] {
                
                conversation.append(newConvo)
                user["conversation"] = conversation
                
                ref.setValue(user) { error, _ in
                    
                    if error == nil{
                        self.addConvoToMainBranch(conversationID: convoID, chattingWithName: chattingWithName, latestMessage: firstMessage, completion: completion)
                        
                        print("successfully added onto existing convo")
                    }else{
                        print("could not add onto existing convo")
                        
                    }
                    
                }
                
                
                
            }else{
                //                create new convo
                
                user["conversation"] = [
                    newConvo
                ]
                
                ref.setValue(user) { error, _ in
                    if error == nil{
                        
                        print("successfully added conversation to firebase")
                        
                        self.addConvoToMainBranch(conversationID: convoID, chattingWithName: chattingWithName, latestMessage: firstMessage, completion: completion)
                    }else{
                        
                        print("there was an error adding your conversation to firebase")
                        
                    }
                }
            }
            
            
            
                            
                
            }
            
            
        
    }
    
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
                print("successfully saved to firebase")
            }else{
                
                print("error saving your converation to firebase")
            }
            
        }
        
        
        
        
        
    }
    
    
    public func getAllConvos(with: String, completion: @escaping (Result<[ConversationModel], Error>)-> Void){
        
        guard let currentEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return}
        
        let ref = databse.reference().child("users").child(currentEmail).child("conversation")
        
        ref.observe(.value) { snapshot in
            
            guard let snapshotData = snapshot.value as? [[String:Any]] else{return}
            
            let conversation : [ConversationModel] = snapshotData.compactMap({ dictionary in
                
                guard let chattingWithName = dictionary["chattingWIthName"] as? String,let chattingWithEmail = dictionary["chattingWithEmail"] as? String, let convoID = dictionary["convoID"] as? String, let latestMessage = dictionary["latestMessage"] as? [String:Any], let date = latestMessage["date"] as? String, let isRead = latestMessage["isRead"] as? Bool, let message = latestMessage["message"] as? String else{return nil}
                
                
                let latestMessageObject = LatestMessage(date: date, isRead: isRead, message: message )
                
                let conversationModel = ConversationModel(chattingWithName: chattingWithName, latestMessage: latestMessageObject, chattingWithEmail: chattingWithEmail, convoID: convoID)
                
                return conversationModel
            })
            
            completion(.success(conversation))
            
            
        }
        
        
        
        
        
    }
    
    public func getAllMessages(with id: String, completion: @escaping ([Message])-> Void){
        
        let ref = databse.reference().child(id).child("messages")
        
        ref.observe(.value) { snapshot in
            
            guard let snapshotValue = snapshot.value as? [[String:Any]] else {return}
            
            let messages : [Message] = snapshotValue.compactMap({ dictionary in
                
                guard let chattingWith = dictionary["chattingWith"] as? String,
                      let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String ,
                      let messageID = dictionary["id"] as? String ,
                      let isRead = dictionary["isRead"] as? Bool ,
                      let senderEmail = dictionary["senderEmail"] as? String ,
                      let type = dictionary["type"]as? String,
                      let formattedDate = ChatViewController.dateFormatter.date(from: date) else {return nil}
                
                
                let senderObject = Sender(senderId: senderEmail, displayName: chattingWith, photoURL: "")
                
                let messageModel = Message(sender: senderObject, messageId: messageID, sentDate: formattedDate, kind: .text(content), isRead: isRead)
                
                return messageModel
            })
            
            completion(messages)
            
            
        }
        
        
        
    }
    
    public func sendMessageToConvof(with conversation: String, message: Message, completion: @escaping (Bool)-> Void){
        
        
    }
    
    
    
    
}

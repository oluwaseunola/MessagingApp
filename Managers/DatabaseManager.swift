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
    
    
    func fetchAllUsers(completion: @escaping ([String])->Void){
        
        let ref = databse.reference().child("users")
        
        ref.getData { error, snapshot in
          
            

            
            if error == nil{
                
                guard let users = snapshot.value as? NSDictionary else{return}
            
                let userList = users.compactMap({$0.value as? NSDictionary})
                let userNames = userList.compactMap({$0["userFirstName"] as? String})
                
                completion(userNames)
              

            }else{
                
                print(error?.localizedDescription)
            }
            
            
            
        }
        
    }
    
    
}

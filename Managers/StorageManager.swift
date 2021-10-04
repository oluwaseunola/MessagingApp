//
//  StorageManager.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-29.
//

import Foundation
import FirebaseStorage

struct StorageManager {
    
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    private init() {
        
    }
    
    public func uploadProfile(email: String, photo: Data, completion: @escaping (Bool)->Void ){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        let ref = storage.child("users").child("\(safeEmail).profilePicture")
        
        ref.putData(photo, metadata: nil) { _ , error in
            
            if error == nil{
                completion(true)
            }else{completion(false)
                print(error?.localizedDescription)
            }
            
        }
        
        
        
        
    }
    
    
    func getUserPicturData(email: String, completion: @escaping (Data)-> Void){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")

        
        
        let ref = storage.child("users").child("\(safeEmail).profilePicture")
        
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            
            guard let data = data else {
                return
            }

            if error == nil{
                completion(data)
            }else{
                print(error?.localizedDescription)
            }
            
            
            
        }
        
    }
    
}

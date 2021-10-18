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
    /// upload profile picture to firebase
    public func uploadProfile(email: String, photo: Data, completion: @escaping (Bool)->Void ){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        let ref = storage.child("users").child("\(safeEmail).profilePicture")
        
        ref.putData(photo, metadata: nil) { _ , error in
            
            if error == nil{
                completion(true)
            }else{completion(false)
                print(error!.localizedDescription)
            }
            
        }
        
        
        
        
    }

    /// download profile picture from firebase

    public func getProfileImage(userEmail: String ,completion: @escaping (URL)-> Void){
        
        let safeEmail = userEmail.replacingOccurrences(of: ".", with: "_")


        let ref = storage.child("users").child("\(safeEmail).profilePicture")
        
        ref.downloadURL { url, error in
            
            guard let url = url else {return}
            
            if error == nil{
                
                completion(url)
            }else{
                print("could not download image url")
            }
            
        }
        
    }
    
    /// upload image message to firebase

    public func uploadImageMessage(email: String, photo: Data, fileName: String, completion: @escaping (Result<URL,Error>)->Void ){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        let ref = storage.child("users").child("\(safeEmail)").child("imageMessages").child(fileName)
        
        ref.putData(photo, metadata: nil) { _ , error in
            if error == nil{
                
                storage.child("users").child("\(safeEmail)").child("imageMessages").child(fileName).downloadURL { url, urlDownloadError in
                    guard let url = url else {
                        return
                    }
                    
                    if urlDownloadError == nil{
                        
                        completion(.success(url))
                    }else{
                        completion(.failure(urlDownloadError!))
                    }
                    
            
                }
            }else{
                print(error!.localizedDescription)
            }

            
        }

        
    }
    /// upload media url to firebase

    public func uploadMediaURLMessage(email: String, media: URL, fileName: String, completion: @escaping (Result<URL,Error>)->Void ){
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        let ref = storage.child("users").child("\(safeEmail)").child("videoMessages").child(fileName)
        
        ref.putFile(from: media, metadata: nil) { _ , error in
            if error == nil{
                
                storage.child("users").child("\(safeEmail)").child("videoMessages").child(fileName).downloadURL { url, urlDownloadError in
                    guard let url = url else {
                        return
                    }
                    
                    if urlDownloadError == nil{
                        
                        completion(.success(url))
                    }else{
                        completion(.failure(urlDownloadError!))
                    }
                    
            
                }
            }else{
                print(error!.localizedDescription)
            }
    
           
            
            
        }
        
        
        
        
    }
    
    
}

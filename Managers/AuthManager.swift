//
//  AuthManager.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-27.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

struct AuthManager{
    
    static let shared = AuthManager()
    
    private init() {
        
    }
    
    func signIn(email: String, password: String, completion:@escaping ((Error?, AuthDataResult?))-> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            
            if error == nil{
                
                completion((error,result))
            }
            else{completion((error,result))

    
            }
            
            
        }
        
        
        
    }
    
    
    func createUser(email: String, password: String, completion:@escaping (AuthDataResult)-> Void){
        
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                guard let safeResult = result else{return}
                
                if error == nil{
                    completion(safeResult)
                }
                else{print(error?.localizedDescription)}
                
        }

        
        
    }
    
    
    func signOut(){
        
        LoginManager().logOut()
        GIDSignIn.sharedInstance.signOut()
        
        do{
            try? Auth.auth().signOut()
                }
        catch{
            
            print(error)
        }
        
    }

    
}

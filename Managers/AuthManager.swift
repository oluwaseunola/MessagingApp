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
    
    
    /// Standard email/password sign in
    func signIn(email: String, password: String, completion:@escaping ((Error?, AuthDataResult?))-> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            
            if error == nil{
                
                completion((error,result))
            }
            else{completion((error,result))

    
            }
            
            
        }
        
        
        
    }
    
    /// Creates new user
    
    func createUser(email: String, password: String, completion:@escaping (Bool)-> Void){
        
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
                                
                if error == nil{
                    print("success creating user")

                    completion(true)
                }
            else{ print(error?.localizedDescription)
                    completion(false)}
                
        }

        
        
    }
    
    /// Sign out User
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

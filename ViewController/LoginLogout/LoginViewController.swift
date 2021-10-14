//
//  LoginViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import JGProgressHUD



class LoginViewController: UIViewController {
    
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookButton)
        scrollView.addSubview(googleButton)
        scrollView.addSubview(spinner)
        
        
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookButton.delegate = self
        googleButton.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        
        googleButton.isUserInteractionEnabled = true
        
        
        
        facebookButton.permissions = ["public_profile", "email"]
        
        if let token = AccessToken.current,
           !token.isExpired {
            AuthManager.shared.signOut()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.width/2
        let size2 = (view.width)*(4/5)
        
        imageView.frame = CGRect(x: (view.width - size)/2, y: 50, width: size, height: size)
        
        scrollView.frame = view.bounds
        
        emailField.frame = CGRect(x: (view.width - size2)/2, y: imageView.bottom + 60, width: size2 , height: 52)
        
        passwordField.frame = CGRect(x: (view.width - size2)/2, y: emailField.bottom + 10, width: size2 , height: 52)
        
        loginButton.frame = CGRect(x: (view.width - size2)/2, y: passwordField.bottom + 10, width: size2 , height: 52)
        
        facebookButton.frame =  CGRect(x: (view.width - size2)/2, y: loginButton.bottom + 10, width: size2 , height: 52)
        
        facebookButton.layer.masksToBounds = true
        facebookButton.layer.cornerRadius = 12
        
        googleButton.frame = CGRect(x: (view.width - size2)/2, y: facebookButton.bottom + 10, width: size2 , height: 52)
        
        googleButton.layer.masksToBounds = true
        googleButton.layer.cornerRadius = 12
        
        
        
    }
    
    //MARK: - Components
    
    
    let spinner = JGProgressHUD(style: .dark)
    let facebookButton = FBLoginButton()
    let googleButton = GIDSignInButton()
    
    
    private let scrollView : UIScrollView = {
        let view = UIScrollView()
        
        view.clipsToBounds = true
        
        
        
        return view
        
    }()
    
    private let imageView : UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "messenger.logo")
        
        imageView.contentMode = .scaleAspectFill
        
        
        
        
        return imageView
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        
        field.placeholder = "Email"
        field.textAlignment = .center
        field.textColor = .label
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        
        
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        
        field.placeholder = "Password"
        field.textColor = .label
        field.isSecureTextEntry = true
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        
        
        return field
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.backgroundColor = .systemBlue
        return button
    }()
    
    
    //MARK: - Regular Login
    
    @objc func didTapLogin(){
        
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUser()
            return
        }
        
        spinner.show(in: view)
        
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            
            
            if result.0 == nil{
                
                UserDefaults.standard.set(email, forKey: "userEmail")
                

                
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                    self?.spinner.dismiss(animated: true)
                }
            } else {
                
                if let unwrappedError = result.0 {
                    
                    let alert = UIAlertController(title: "Login Error", message: "\( unwrappedError.localizedDescription)", preferredStyle: .alert)
                    
                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    
                    alert.addAction(dismiss)
                    
                    self?.present(alert, animated: true, completion: nil)
                    
                    self?.spinner.dismiss(animated: true)
                }
                
                
            }
            
            
            
            
            
            
        }
        
        
        
    }
    
    
    
    
    
    
    //MARK: - Google Login
    
    @objc func didTapGoogleLogin(){
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            
            guard let unwrappedResult = user else{return}
            
            guard let firstName = unwrappedResult.profile?.givenName, let lastName = unwrappedResult.profile?.familyName, let email = unwrappedResult.profile?.email else {return}
            
            guard let profilePicURL = user?.profile?.imageURL(withDimension: 320) else {return}

            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            DatabaseManager.shared.validateNewUser(email: email) { exists in
                
                print(" does this exist?: \(exists)")
                if !exists{
                    DatabaseManager.shared.saveUser(user: UserModel(firstName: firstName, lastName: lastName, email: email))
                    
                    
                }
                
                Auth.auth().signIn(with: credential) { result, error in
                    
                    if error == nil {
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(email, forKey: "userEmail")
                            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "userName")
                            


                            self?.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                    
                }
                
                
                
            }
            
            
            URLSession.shared.dataTask(with: profilePicURL) { photoDataURL, _, error in
               
                print("attempting to upload google profile picture to firebase")
                
                guard let photoDataURL = photoDataURL else {
                    return
                }
                
                if error == nil{
                    
                    StorageManager.shared.uploadProfile(email: email, photo: photoDataURL) { success in
                        if success{
                            print("profile picture successfully uploaded from google")
                        }else{
                            
                            print("Error uploading google profile picture to firebase")
                        }
                        
                    }
                    
                }else{
                    print("Could not get google image URL data")

                }
            }
            .resume()
          
            
        }
    }
    
    func alertUser(){
        
        let alert = UIAlertController(title: "Error", message: "Please enter a valid email and password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func didTapRegister(){
        
        let vc = RegisterViewController()
        
        vc.title = "Register"
        
        navigationController?.pushViewController( vc, animated: true)
        
    }

    
    
    
}

extension LoginViewController : UITextFieldDelegate, LoginButtonDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            
            passwordField.becomeFirstResponder()
        }else{
            resignFirstResponder()
            
        }
        
        return true
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {return}
        
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        
        let facebookrequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookrequest.start { _, reqResults, reqError in
            guard let unwrappedResults = reqResults as? [String : Any], reqError == nil else {
                print("there was an error fetching results")
                return
            }
            
            
            guard let email = unwrappedResults["email"] as? String else{return}
            guard let firstName = unwrappedResults["first_name"] as? String else {return}
            guard let lastName = unwrappedResults["last_name"] as? String else{return}
            
            guard let picture = unwrappedResults["picture"] as? [String : Any], let data = picture["data"] as? [String : Any], let photoString = data["url"] as? String else{return}
            
            guard let photoURL = URL(string: photoString) else{return}
            
            
            DatabaseManager.shared.validateNewUser(email: email) { exists in
                
                if !exists{
                    DatabaseManager.shared.saveUser(user: UserModel(firstName: firstName, lastName: lastName, email: email))
                    
                }
                
                
                Auth.auth().signIn(with: credential) { [weak self] _, authError in
                    
                    guard authError == nil else{
                        print("something went wrong with facebook login")
                        return
                    }
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "userName")
                    


                    self?.dismiss(animated: true)
                }
            }
            
            
            let session = URLSession.shared.dataTask(with: photoURL) { photoURLData, _, photoError in
                
                
                guard let photoURLData = photoURLData else {
                    return
                }
                
                if photoError == nil{
                    
                    print("uploading facebook photo data to firebase")
                    
                    StorageManager.shared.uploadProfile(email: email, photo: photoURLData) { success in
                        if success{
                            print("profile picture successfully uploaded from facebook")
                        }else{
                            
                            print("Error uploading facebook profile picture to firebase")
                        }
                        
                    }
                    
                }else{
                    print("Error getting profile data from facebook")

                }
                
                
            }
            
            session.resume()
            
            
        }
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
}














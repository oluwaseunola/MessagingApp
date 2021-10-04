//
//  RegisterViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit
import JGProgressHUD


class RegisterViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    
    let spinner = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
      
        
        view.addSubview(scrollView)
        view.addSubview(profileImage)
        view.addSubview(firstName)
        view.addSubview(lastName)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile))
        
        profileImage.addGestureRecognizer(tapGesture)
        
        profileImage.isUserInteractionEnabled = true
      
        emailField.delegate = self
        passwordField.delegate = self
        imagePicker.delegate = self

        scrollView.addSubview(profileImage)
        scrollView.addSubview(firstName)
        scrollView.addSubview(lastName)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(spinner)


    }
    
    private let scrollView : UIScrollView = {
        let view = UIScrollView()
        
        view.clipsToBounds = true
        
        
        
        return view
        
    }()
    
    private let profileImage : UIImageView = {
        
       let profile = UIImageView()
       
        profile.image = UIImage(systemName: "person.circle.fill")
        profile.contentMode = .scaleAspectFill
        profile.tintColor = .darkGray
        profile.layer.masksToBounds = true
        profile.layer.borderWidth = 1
        
        
    
        return profile
    }()
    
    private let firstName : UITextField = {
        let field = UITextField()
        
        field.placeholder = "First Name"
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        
        
        return field
    }()
    
    private let lastName : UITextField = {
        let field = UITextField()
        
        field.placeholder = "Last Name"
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.darkGray.cgColor
        
        
        return field
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        
        field.placeholder = "Email"
        field.textAlignment = .center
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
    
    private let registerButton : UIButton = {
        let button = UIButton()
        
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.backgroundColor = .systemGreen
        return button
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.width/3
        let size2 = (view.width)*(4/5)
        
        profileImage.frame = CGRect(x: (view.width - size)/2, y: size + 20, width: size, height: size)
        
        profileImage.layer.cornerRadius = size/2
    
        scrollView.frame = view.bounds
        
        
        firstName.frame = CGRect(x: (view.width - size2)/2, y: profileImage.bottom + 100, width: size2 , height: 52)
        
        lastName.frame = CGRect(x: (view.width - size2)/2, y: firstName.bottom + 10, width: size2 , height: 52)
        
        emailField.frame = CGRect(x: (view.width - size2)/2, y: lastName.bottom + 10, width: size2 , height: 52)
        
        passwordField.frame = CGRect(x: (view.width - size2)/2, y: emailField.bottom + 10, width: size2 , height: 52)
        
        registerButton.frame = CGRect(x: (view.width - size2)/2, y: passwordField.bottom + 10, width: size2 , height: 52)

        
    
    }

    
    
    @objc func didTapRegister(){
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6, let name = firstName.text, let last = lastName.text else{
            alertUser()
            return
        }
        
        spinner.show(in: view)
        
//        Validate new user to see if they already exist
        
        DatabaseManager.shared.validateNewUser(email: email) { [weak self] exists in
            
            if exists{
                
                let alert = UIAlertController(title: "Error", message: "An account with this email already exists", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                
                alert.addAction(dismiss)
                
                self?.present(alert, animated: true, completion: nil)
            }
            
            
        }
        
//        Create new user for authentication if they do not already exist
        
        AuthManager.shared.createUser(email: email, password: password) { [weak self] result in
            
            print("Created user: \(result.user)")
            
            DispatchQueue.main.async {
                self?.spinner.dismiss(animated: true)
                self?.dismiss(animated: true, completion: nil)

            }
        }
    
//        This saves the user to our database
        
        DatabaseManager.shared.saveUser(user: UserModel(firstName: name, lastName: last , email: email))
    
        
            
        guard let photoData = profileImage.image?.pngData() else{return}
            
//            This uploads our new user's profile picture to firebase storage
            
            StorageManager.shared.uploadProfile(email: email, photo: photoData) { success in
                if success{
                    print("profile picture successfully uploaded")
                }else{
                    
                    print("Error uploading profile picture")
                }
            
        }
        
        
    }
    
    func alertUser(){
        
        let alert = UIAlertController(title: "Error", message: "Please enter a valid email and password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
   
    
    
    
    @objc func didTapProfile(){
        
        let actionSheet = UIAlertController(title: "Change Image", message: nil, preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            
            self?.imagePicker.sourceType = .camera
            self?.imagePicker.allowsEditing = true
            
        }
        
        let choosePhoto = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            
            self?.present(self?.imagePicker ?? UIImagePickerController() , animated: true, completion: nil)

        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(choosePhoto)
        actionSheet.addAction(cancel)
        
    present(actionSheet, animated: true)
        
    }
    

}

extension RegisterViewController : UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        if textField == emailField{
            
            passwordField.becomeFirstResponder()
        }else{
            resignFirstResponder()
            
        }
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else{return}
        
        profileImage.image = selectedImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }

}

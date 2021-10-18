//
//  ProfileViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
   
    
    @IBOutlet var logOutButton : UIButton?
    @IBOutlet var tableView : UITableView?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView?.tableHeaderView = profileHeaderView()
        view.backgroundColor = .systemBackground
        configureTableView()
        listenForLogin()

    }
    
    private let label = UILabel()
    private let profileImageView = UIImageView()
    private var data : [LoginTableViewRows] = [LoginTableViewRows]()
    
    
    private func listenForLogin(){
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("isLoggedIn"), object: nil, queue: .main) { [weak self] _ in
           
            self?.fetchImage()

            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("registeredNewUser"), object: nil, queue: .main) {[weak self] _ in
            self?.fetchImage()
        }
    }

    private func profileHeaderView()-> UIView?{
        
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else{return nil}
        
        let headerView = UIView()
        
        label.textAlignment = .center
        
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.frame = CGRect(x: (self.view.width - 100)/2, y: 50, width: 100, height: 100)
        label.frame = CGRect(x: self.view.width/2, y: profileImageView.bottom + 10, width: self.view.width, height: 52)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderWidth = 3

        

        StorageManager.shared.getProfileImage(userEmail:email) {[weak self] url in
            
            self?.profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 250)
        headerView.addSubview(profileImageView)
        headerView.addSubview(label)
        
        
        
        return headerView
    }
    
    
    private func configureTableView(){
        
        data.append(LoginTableViewRows(title: "Log Out", kind: .logout, completion: { [weak self] in
            
            let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default) {  _ in
               
                AuthManager.shared.signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                
                nav.modalPresentationStyle = .fullScreen
                
                self?.present(nav, animated: true, completion: nil)
                
            }
            
            let no = UIAlertAction(title: "No", style: .default, handler: nil)
            
            alert.addAction(yes)
            alert.addAction(no)
            
            self?.present(alert, animated: true, completion: nil)
        }))
        
        data.append(LoginTableViewRows(title: "Email", kind: .info, completion: nil))
    }
    
    private func fetchImage(){
        
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else{return}
        
        tableView?.reloadData()
        
        StorageManager.shared.getProfileImage(userEmail:email) {[weak self] url in
            
            self?.profileImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    
}

extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {return UITableViewCell()}
        
        let model = data[indexPath.row]
        
        cell.configure(model: model)
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        data[indexPath.row].completion?()
        
        
    }
}

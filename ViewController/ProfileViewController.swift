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
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.tableHeaderView = profileHeaderView()

    }
    
    
    private func profileHeaderView()-> UIView?{
        
        guard let email = UserDefaults.standard.string(forKey: "userEmail") else{return nil}
        
        let headerView = UIView()
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.frame = CGRect(x: (self.view.width - 100)/2, y: 50, width: 100, height: 100)
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.borderWidth = 3
        

        StorageManager.shared.getProfileImage(userEmail:email) { url in
            profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 250)
        headerView.addSubview(profileImageView)
        
        
        
        return headerView
    }
    
    
    
    
    
}

extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == 0 {
        cell.textLabel?.text = "Log Out"
        cell.textLabel?.textColor = .systemRed
        cell.textLabel?.textAlignment = .center
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            AuthManager.shared.signOut()
            
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            
            nav.modalPresentationStyle = .fullScreen
            
            self?.present(nav, animated: true, completion: nil)
            
        }
        
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(yes)
        alert.addAction(no)
        
        present(alert, animated: true, completion: nil)
        
        
        
    }
}

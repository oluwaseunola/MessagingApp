//
//  ProfileTableViewCell.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-13.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(model: LoginTableViewRows){
        
        switch model.kind{
            
        case .logout:
            self.textLabel?.text = model.title
            self.textLabel?.textAlignment = .center
            self.textLabel?.textColor = .red
        case .info:
            guard let email = UserDefaults.standard.string(forKey: "userEmail") else{return}
            
            self.textLabel?.text = email
            self.textLabel?.textAlignment = .center
        }
        
    }
   

}

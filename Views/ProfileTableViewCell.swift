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
            textLabel?.text = model.title
            textLabel?.textAlignment = .center
            textLabel?.textColor = .red
        case .info:
            guard let email = UserDefaults.standard.string(forKey: "userEmail") else{return}
            
            textLabel?.text = email
            textLabel?.textAlignment = .center
        }
        
    }
   

}

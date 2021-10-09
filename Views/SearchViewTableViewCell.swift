//
//  SearchViewTableViewCell.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-08.
//

import UIKit
import SDWebImage

class SearchViewTableViewCell: UITableViewCell {

    static let identifier = "SearchViewTableViewCell"

    private let profile : UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        
        
        return imageView
        
    }()
    
    private let userNameLabel : UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        label.text = "Ben baller"

        
        return label
        
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profile)
        contentView.addSubview(userNameLabel)
        


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profile.frame = CGRect(x: 10, y: (contentView.height-50)/2, width: 50, height: 50)
        
        userNameLabel.frame = CGRect(x: profile.right + 30, y: (contentView.height - 20)/2, width: contentView.width - 10 - profile.width, height: 25)
        
        
        
    }
    
    override func prepareForReuse() {
        profile.image = nil
        userNameLabel.text = nil
        
    }
    
    public func configureCell(model: [String:String]){
        guard let firstName = model["userFirstName"], let lastName = model["userLastName"], let email = model["userEmail"] else {return}
        
        let safeEmail = email.replacingOccurrences(of: ".", with: "_")
        
        userNameLabel.text = "\(firstName) \(lastName)"
        
        
        StorageManager.shared.getProfileImage(userEmail: safeEmail) { [weak self] url in
           self?.profile.sd_setImage(with: url, completed: nil)
        }
        
        
    }
    

}

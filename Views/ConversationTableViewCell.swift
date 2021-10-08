//
//  ConversationTableViewCell.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-05.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"

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
    
    private let messageLabel : UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = "Hey Bro"
        
        return label
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profile)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(messageLabel)


    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profile.frame = CGRect(x: 10, y: (contentView.height-50)/2, width: 50, height: 50)
        
        userNameLabel.frame = CGRect(x: profile.right + 15, y: profile.top, width: contentView.width - 10 - profile.width, height: 20)
        
        messageLabel.frame = CGRect(x: profile.right + 15, y: userNameLabel.bottom + 5, width: contentView.width - 35 - profile.width, height: contentView.height - 50 - 30)
        
        
    }
    
    override func prepareForReuse() {
        profile.image = nil
        messageLabel.text = nil
        userNameLabel.text = nil
        
    }
    
    public func configureCell(model: ConversationModel){
        
        userNameLabel.text = model.chattingWithName
        messageLabel.text = model.latestMessage.message
        
        let safeEmail = model.chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        
        StorageManager.shared.getProfileImage(userEmail: safeEmail) { [weak self] url in
           self?.profile.sd_setImage(with: url, completed: nil)
        }
        
        
    }
    
    
    
    
    
    
}

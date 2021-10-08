//
//  ChatViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-28.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

class ChatViewController: MessagesViewController, MessageCellDelegate {
    
    
    
    static let dateFormatter : DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        
        
        return formatter
    }()
    
    private var messages = [Message]()
    
    private var sender : Sender? {
        guard let safeEmail = UserDefaults.standard.string(forKey: "userEmail") else {return nil}
        
        return Sender(senderId: safeEmail, displayName: "me", photoURL: "")
        
    }
    private var mediaURL : URL?
    public var chattingWithEmail: String
    public var chattingWithName : String
    private var convoID : String?
    private let imagePicker = UIImagePickerController()
    
    
    private var isNewConvo = true
    
    init(chattingWithEmail: String, chattingWithName: String, convoID: String?) {
        self.chattingWithEmail = chattingWithEmail
        self.chattingWithName = chattingWithName
        self.convoID = convoID
        super.init(nibName: nil, bundle: nil)
        
        if let convoID = convoID {
            listenForMessages(id: convoID)
        }
        
        
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messageCellDelegate = self
        configureButtons()
        imagePicker.delegate = self
        
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        configureScroll()
        
        if !self.messages.isEmpty{
            isNewConvo = false
        }
    }
    
    //MARK: - functions
    
    
    public func listenForMessages(id: String){
        
        DatabaseManager.shared.getAllMessages(with: id) { [weak self] allMessages in
            
            
            self?.messages = allMessages
            
            DispatchQueue.main.async {
                
                self?.messagesCollectionView.reloadDataAndKeepOffset()
            }
            
        }
        
    }
    
    private func configureScroll(){
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        messageInputBar.inputTextView.becomeFirstResponder()
        
            }
    
    private func configureButtons(){
        let selectImageButton = InputBarButtonItem()
        selectImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        selectImageButton.onTouchUpInside { [weak self] _ in
            
            self?.presentPhotoActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([selectImageButton], forStack: .left, animated: true)
        
        
    }
    
    private func presentPhotoActionSheet(){
        
        let actionSheet = UIAlertController(title: "Send photo", message: nil, preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Take photo", style: .default) { [weak self] _ in
            self?.imagePicker.sourceType = .camera
            self?.imagePicker.allowsEditing = true
            
            
            self?.present(self!.imagePicker, animated: true, completion: nil)
            
        }
        
        let chooseFromLibrary = UIAlertAction(title: "Choose from library", style: .default) { [weak self] _ in
            self?.imagePicker.allowsEditing = true
            self?.present(self!.imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(chooseFromLibrary)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
        
        
        
    }
    
    
}

extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate{
    
    func currentSender() -> SenderType {
        if let sender = self.sender {
            return sender
        }
        
        fatalError("Self sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let safeSender = self.sender else{return}
        
        let message = Message(sender: safeSender , messageId: createMessageID(), sentDate: Date() , kind: .text(text), isRead: false)
        
        
        
        
        if isNewConvo {
            
            
            
            DatabaseManager.shared.createNewConvo(chattingWithEmail: chattingWithEmail, chattingWithName: chattingWithName, firstMessage: message) { [weak self] success in
                
                if success{
                    print("less goo")
                    self?.isNewConvo = false
                } else{
                    
                    print("error creating new convo in firebase")
                }
                
            }
            
        }else{
            guard let id = convoID else{return}
            
            DatabaseManager.shared.sendMessageToConvof(with: id, chattingWithEmail: chattingWithEmail, chattingWithName: chattingWithName, message: message) { success in
                
                if success{
                    print("success appending to conversation")
                }else{
                    print("error appending to conversation")
                    
                }
                
            }
            
        }
        
    }
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind{
            
        
        case .text(_):
            break
        case .attributedText(_):
            break
        case .photo(let media):
            
            guard let url = media.url else{return}
            
            imageView.sd_setImage(with:url) { _, error, _, _ in
                if error == nil {
                    print("successfully recieved image messge")
                }else{
                    print("error receiving image message")
                }
            }
            
            
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        

        
            
    
        
        
    }
    
    private func createMessageID()-> String{
        
        guard let safeEmail = UserDefaults.standard.string(forKey: "userEmail")?.replacingOccurrences(of: ".", with: "_") else {return ""}
        
        
        let safeChattingWithEmail = chattingWithEmail.replacingOccurrences(of: ".", with: "_")
        let messageID = "\(safeEmail)_\(ChatViewController.dateFormatter.string(from: Date()))_\(safeChattingWithEmail)"
        
        return messageID
        
    }
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
       
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else{return}
        
        let message = messages[indexPath.section]
        
        switch message.kind{
            
            
        case .text(_):
            break
        case .attributedText(_):
            break

        case .photo(let media):
            
            guard let url = media.url else{ print("no url here")
                return}
            
            let vc = PhotoViewerViewController(url: url)
        
            present(vc, animated: true, completion: nil)
            
        case .video(_):
            break

        case .location(_):
            break

        case .emoji(_):
            break

        case .audio(_):
            break

        case .contact(_):
            break

        case .linkPreview(_):
            break

        case .custom(_):
            break

        }
    }
    
    
    
}

extension ChatViewController : UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        dismiss(animated: true, completion: nil)

        guard let image = info[.editedImage] as? UIImage else {print("no image")
            return}
        guard let imageData = image.pngData()else {print("no data")
            return}
        guard let userEmail = UserDefaults.standard.string(forKey: "userEmail") else {print("no email")
            return}
        guard let convoID = convoID else {print("no id")
            return}
        guard  let sender = self.sender else {print("no sender")
            return}
        guard let placeHolder = UIImage(systemName: "photo") else {print("no holder")
            return}
        
        
    
        
        let fileName = "imageMessage_\(createMessageID())"
        
        
        
        
        StorageManager.shared.uploadImageMessage(email: userEmail, photo: imageData, fileName: fileName ) {[weak self] result in
            
            
            switch result{
                
            case .success(let url):
                
                
                
                let mediaObject = Media(url: url, image: image, placeholderImage: placeHolder, size: .zero)
                
                let message = Message(sender: sender , messageId: convoID, sentDate: Date(), kind: .photo(mediaObject), isRead: false)
                
                
                DatabaseManager.shared.sendMessageToConvof(with: convoID, chattingWithEmail: self?.chattingWithEmail ?? "", chattingWithName: self?.chattingWithName ?? "", message: message) { success in
                    
                    if success{
                        print("uploaded image message")
                    }else{
                        print("error uploading image message")
                    }
                    
                }
                

            case.failure(let error):
                
                print(error.localizedDescription)
                
            }
            
        }
        
        

    }
    
}

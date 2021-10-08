//
//  PhotoViewerViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {
    
    var url : URL
    
    init(url: URL) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let imageView : UIImageView = {
        let view = UIImageView()
    
        view.contentMode = .scaleAspectFit
        view.layer.masksToBounds = true
        
        return view
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        view.backgroundColor = .black
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds

    }
    
    
    

}

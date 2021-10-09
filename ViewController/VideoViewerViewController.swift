//
//  VideoViewerViewController.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-09-23.
//
import AVFoundation
import AVKit
import UIKit

class VideoViewerViewController: UIViewController {

    var url : URL
    let playerController = AVPlayerViewController()

    
    
    init(url: URL) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(playerController.view)
        view.backgroundColor = .black
        configureAVPLayer(url: url)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerController.view.frame = view.bounds

    }
    
    private func configureAVPLayer(url: URL){
        
        let player = AVPlayer(url: url)
        playerController.player = player
        present(playerController, animated: true, completion: nil)
        playerController.player?.play()
    }
    


}

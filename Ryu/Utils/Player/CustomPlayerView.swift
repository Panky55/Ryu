//
//  CustomPlayerView.swift
//  Ryu
//
//  Created by Francesco on 24/08/24.
//

import UIKit
import AVKit

class CustomPlayerView: UIViewController {
    
    private var playerView: CustomVideoPlayerView!
    
    private var videoTitle: String?
    private var videoURL: URL?
    weak var delegate: CustomPlayerViewDelegate?
    
    init(videoTitle: String, videoURL: URL) {
        self.videoTitle = videoTitle
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupAudioSession()
        
        playerView = CustomVideoPlayerView(frame: view.bounds)
        view.addSubview(playerView)
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let videoURL = videoURL {
            playerView.setVideo(url: videoURL, title: videoTitle ?? "")
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("Failed to set up AVAudioSession: \(error)")
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerView.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.customPlayerViewDidDismiss()
    }
}

protocol CustomPlayerViewDelegate: AnyObject {
    func customPlayerViewDidDismiss()
}

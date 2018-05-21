//
//  PlayerViewController.swift
//  CloudinaryTest
//
//  Created by Olya Tilichenko on 18.05.2018.
//  Copyright © 2018 Olga. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var stringUrl: String?
    
    @IBOutlet weak var playSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.addTarget(self, action: #selector(self.back))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        let stop = UITapGestureRecognizer()
        self.view.addGestureRecognizer(stop)
        stop.addTarget(self, action: #selector(self.stopPlaying))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let url = URL(string: stringUrl!)
        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        self.view.layer.addSublayer(playerLayer)
        self.view.addSubview(playSlider)
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playSlider.maximumValue = Float(seconds)
        playSlider.minimumValue = 0
        playSlider.isContinuous = true
        playSlider.setThumbImage(UIImage(), for: .normal)
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        
        playSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)

        player?.play()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }
        
    @objc func playbackSliderValueChanged(_ playSlider:UISlider)
        {
            if let duration = player?.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(duration)
                
                let value = Float64(playSlider.value) * totalSeconds
                
                let seekTime = CMTime(value: Int64(value), timescale: 1)
                
                player?.seek(to: seekTime)
                
                if player!.rate == 0
                {
                    player?.play()
                }
                
            }
        }
    
    @objc func updateSlider()
    {
        let currentTimeInSeconds = CMTimeGetSeconds((player?.currentTime())!)
        playSlider.value = Float(currentTimeInSeconds)
    }
    
    @objc func stopPlaying() {
        if (player?.rate == 1.0 ) {
            player?.pause()
        } else {
            player?.play()
        }
    }
}

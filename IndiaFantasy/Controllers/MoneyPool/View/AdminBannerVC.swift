//
//  AdminBannerVC.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 24/06/24.
//

import UIKit
import AVFoundation

class AdminBannerVC: UIViewController {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var btnPlayVideo: UIButton!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false
    var bannerData: AdminBannersResult? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showAnimate()
        guard let banner = bannerData, let type = banner.type, let mediaURL = banner.mediaURL else {
            dismiss(animated: false)
            return
        }
        
        if type == "image" {
            btnPlayVideo.isHidden = true
            imgBanner.loadImage(urlS: mediaURL, placeHolder: nil)
        }else {
            btnPlayVideo.isHidden = false
            //imgBanner.loadImage(urlS: banner.thumbnailURL, placeHolder: nil)
            
            guard let videoURL = URL(string: mediaURL) else { return }
            player = AVPlayer(url: videoURL)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = viewMain.bounds
            playerLayer?.videoGravity = .resizeAspectFill
            viewMain.layer.addSublayer(playerLayer!)
            //playerLayer?.isHidden = true
            
            // Add observer for player status
            player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            // Add observer for player item's end time
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    
    deinit {
        player?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //MARK: - Observing Player Status
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.status == .readyToPlay {
                // Player is ready to play
                btnPlayVideo.isHidden = false
                player?.play()
                isPlaying = true
                btnPlayVideo.setImage(UIImage(systemName: ""), for: .normal)
                imgBanner.isHidden = true
                playerLayer?.isHidden = false
            }
        }
    }

    //MARK: - Cancel Btn Action
    @IBAction func btnCancelAction(_ sender: UIButton) {
        player = nil
        dismiss(animated: true)
    }
    
    //MARK: - Play Pause Video Btn Action
    @IBAction func btnPlayVideoAction(_ sender: UIButton) {
        
        if isPlaying {
            player?.pause()
            isPlaying = false
            btnPlayVideo.setImage(UIImage(named: "ic_play"), for: .normal)
        } else {
            player?.play()
            isPlaying = true
            btnPlayVideo.setImage(UIImage(systemName: ""), for: .normal)
            imgBanner.isHidden = true
            playerLayer?.isHidden = false
        }
    }
    
    //MARK: - Video Did Finished Observer
    @objc func playerDidFinishPlaying(notification: Notification) {
        //imgBanner.isHidden = false
        //playerLayer?.isHidden = true
        btnPlayVideo.setImage(UIImage(named: "ic_play"), for: .normal)
        isPlaying = false
        
        // Reset player to beginning
        player?.seek(to: CMTime.zero)
        player?.pause()
    }
}

//MARK: - Show Animation
extension AdminBannerVC {
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}

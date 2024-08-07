//
//  MemeViewCell.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 9.07.2024.
//

import UIKit
import AVKit
import Kingfisher
import CommonUtils

// MARK: - Lifecycle
class MemeViewCell: UITableViewCell {
    
    // Outlets
    private var memeImageView: UIImageView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var overlayView: UIView!
    
    // MARK: Overwritten methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15))
        playerLayer?.frame = contentView.bounds
        overlayView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        memeImageView.kf.cancelDownloadTask()
        memeImageView.image = nil
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        memeImageView.isHidden = false
        overlayView.isHidden = true
    }
}

// MARK: - Cell configuration
extension MemeViewCell {
    private func setupCell() {
        contentView.backgroundColor = UIColor(named: "MemeBlockBackground")
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        selectionStyle = .none
        
        memeImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            return imageView
        }()
        
        overlayView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0, alpha: 1)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFit
            view.clipsToBounds = true
            view.isHidden = true
            return view
        }()
        
        contentView.addSubview(memeImageView)
        contentView.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            memeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func setupWithImage(url: URL) {
        let loadingPlaceholder = UIImage(named: "loadingPlaceholder")
        memeImageView.kf.indicatorType = .activity
        memeImageView.kf.setImage(with: url, placeholder: loadingPlaceholder)
        memeImageView.isHidden = false
    }
    
    func setupWithVideo(url: URL) {
        memeImageView.isHidden = true
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        contentView.layer.addSublayer(playerLayer!)
        playerLayer?.frame = contentView.bounds
        if SettingsManager.allowVideoAutoplay {
            player?.play()
            overlayView.isHidden = true
        } else {
            overlayView.isHidden = false
        }
    }
    
    func setupDefault() {
        memeImageView.image = UIImage(named: "ErrorImagePlaceholder")
        memeImageView.isHidden = false
    }
}

extension MemeViewCell {
    func accessPlayer() -> AVPlayer? {
        return player
    }
}

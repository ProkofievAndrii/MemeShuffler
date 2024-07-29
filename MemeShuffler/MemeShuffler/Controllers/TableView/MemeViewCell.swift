//
//  MemeViewCell.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 9.07.2024.
//

import UIKit
import AVKit
import Kingfisher

// MARK: - Lifecycle
class MemeViewCell: UITableViewCell {
    
    // Outlets
    private var memeImageView: UIImageView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
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
    }
}

// MARK: - Cell configuration
extension MemeViewCell {
    // Cell UI
    private func setupCell() {
        contentView.backgroundColor = UIColor(named: "MemeBlockColor")
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        selectionStyle = .none
        
        memeImageView = UIImageView()
        memeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(memeImageView)
        
        NSLayoutConstraint.activate([
            memeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        memeImageView.contentMode = .scaleAspectFit
        memeImageView.clipsToBounds = true
    }
    
    // MARK: Configuration Types
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
        playerLayer?.frame = contentView.bounds
        contentView.layer.addSublayer(playerLayer!)
        player?.play()
    }
    
    func prepareForVideo() {
        memeImageView.isHidden = true
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

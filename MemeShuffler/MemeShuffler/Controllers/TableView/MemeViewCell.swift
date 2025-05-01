//
//  MemeViewCell.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 9.07.2024.
//

import UIKit
import AVKit
import CommonUtils
import Kingfisher

class MemeViewCell: UITableViewCell {
    private var memeImageView: UIImageView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    // MARK: - Init
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
    private func setupCell() {
        contentView.backgroundColor = UIColor(named: "MemeBlockBackground")
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        selectionStyle = .none

        memeImageView = UIImageView()
        memeImageView.translatesAutoresizingMaskIntoConstraints = false
        memeImageView.contentMode = .scaleAspectFit
        memeImageView.clipsToBounds = true
        contentView.addSubview(memeImageView)

        NSLayoutConstraint.activate([
            memeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func setupWithImage(url: URL) {
        let placeholder = UIImage(named: "loadingPlaceholder")
        memeImageView.kf.indicatorType = .activity
        memeImageView.kf.setImage(with: url, placeholder: placeholder)
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
        }
    }

    func setupDefault() {
        memeImageView.image = UIImage(named: "ErrorImagePlaceholder")
        memeImageView.isHidden = false
    }

    func setupWithImageData(_ data: Data) {
        memeImageView.isHidden = false
        if let image = UIImage(data: data) {
            memeImageView.image = image
        } else {
            setupDefault()
        }
    }

    func setupWithLocalMedia(_ data: Data, type: String) {
        switch type.lowercased() {
        case "image", "gif":
            setupWithImageData(data)
        case "video":
            let filename = UUID().uuidString + ".mp4"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            do {
                try data.write(to: url)
                setupWithVideo(url: url)
            } catch {
                setupDefault()
            }
        default:
            setupDefault()
        }
    }
}

extension MemeViewCell {
    func accessPlayer() -> AVPlayer? {
        return player
    }
}

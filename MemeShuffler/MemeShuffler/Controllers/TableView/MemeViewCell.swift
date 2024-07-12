//
//  MemeTableViewCell.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit
import Kingfisher

//MARK: - Lifecycle
class MemeViewCell: UITableViewCell {
    
    //Outlets
    private var memeImageView: UIImageView!
    
    //MARK: Overwritten methods
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
    }
}

//MARK: - Cell configuration
extension MemeViewCell {
    //Cell UI
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
    
    func configureWith(url: String) {
        if let imageUrl = URL(string: url) {
            let loadingPlaceholder = UIImage(named: "loadingPlaceholder")
            memeImageView.kf.indicatorType = .activity
            memeImageView.kf.setImage(with: imageUrl, placeholder: loadingPlaceholder)
        } else {
            memeImageView.image = UIImage(named: "ErrorImagePlaceholder")
        }
    }
    
    //Default image setup
    func configureDefault() {
        memeImageView.image = UIImage(named: "ErrorImagePlaceholder")
    }
}

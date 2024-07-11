//
//  MemeTableViewCell.swift
//  MemeShuffler
//
//  Created by Andrii Prokofiev on 10.07.2024.
//

import UIKit

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
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
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
    
    func configureWith(meme: String) -> MemeViewCell {
        return self
    }
    
    //Default image setup
    func configureDefault() -> MemeViewCell {
        memeImageView.image = UIImage(named: "ErrorImageTemplate")
        return self
    }
}

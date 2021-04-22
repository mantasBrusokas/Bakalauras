//
//  PostTableViewCell.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-22.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {
    
    static let indetifier = "PostTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let postMessage: UITextView = {
        let text = UITextView()
        text.font = .systemFont(ofSize: 19, weight: .regular)
        return text
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(postMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 10, height: 10)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10,
                                     width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
        postMessage.frame = CGRect(x: 10, y: userImageView.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
    }
    
    public func configure(with model: Post) {
        self.postMessage.text = model.text.description
        self.userNameLabel.text = model.authorName
        
        let path = "images/\(model.email)_profile_picture.png"
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
            
        })
    }
}

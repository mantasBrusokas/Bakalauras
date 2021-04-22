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
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let postDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let runningDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.textColor = .systemGreen
        return label
    }()
    
    private let runningDateLabel1: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.textColor = .systemGreen
        label.text = "Planing to run at"
        return label
    }()
    
    private let postMessage: UILabel = {
        let text = UILabel()
        text.font = .systemFont(ofSize: 19, weight: .regular)
        text.numberOfLines = 0
        return text
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(postMessage)
        contentView.addSubview(postDateLabel)
        contentView.addSubview(runningDateLabel)
        contentView.addSubview(runningDateLabel1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 50, height: 50)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10,
                                     width: contentView.width - 100, height: 30)
        postDateLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom,
                                     width: contentView.width - 100, height: 15)
        runningDateLabel.frame = CGRect(x: runningDateLabel1.right, y: userImageView.bottom,
                                     width: contentView.width - 100, height: 30)
        runningDateLabel1.frame = CGRect(x: 10, y: userImageView.bottom,
                                         width: 150, height: 30)
        postMessage.frame = CGRect(x: 10, y: postDateLabel.bottom,
                                   width: contentView.width - 20, height: 100)
    }
    
    public func configure(with model: Post) {
        self.postMessage.text = model.text.description
        self.userNameLabel.text = model.authorName
        self.postDateLabel.text = model.date
        self.runningDateLabel.text = model.runningDate
        
        let path = "images/\(model.email)_profile_picture.png"
        
        
        print("\(model.email)")
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                    
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
                let url1 = URL(string: "https://firebasestorage.googleapis.com/v0/b/findarunningpartner-998ed.appspot.com/o/images%2Fno-avatar.png?alt=media&token=b3967fae-d169-4fdb-a123-341c8ea645d0")
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url1, completed: nil)
                }
            }
            
        })
    }
}

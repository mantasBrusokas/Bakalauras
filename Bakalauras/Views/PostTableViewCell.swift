//
//  PostTableViewCell.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-22.
//

import UIKit
import SDWebImage
import MapKit

class PostTableViewCell: UITableViewCell {
    
    static let indetifier = "PostTableViewCell"
    
    private let pin = MKPointAnnotation()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isUserInteractionEnabled = false
        map.sizeToFit()
        return map
    }()
    
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
        contentView.addSubview(mapView)
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
        runningDateLabel.frame = CGRect(x: 10, y: userImageView.bottom,
                                     width: contentView.width - 100, height: 30)
        postMessage.frame = CGRect(x: 10, y: runningDateLabel.bottom,
                                   width: contentView.width - 20, height: 60)
        mapView.frame = CGRect(x: 10, y: postMessage.bottom,
                               width: contentView.width - 20, height: 200)
    }
    
    public func configure(with model: Post) {
        self.mapView.centerToLocation(model.location.location)
        
        self.pin.coordinate = model.location.location.coordinate
        self.pin.title = "Start Point"
        self.postMessage.text = model.text.description
        self.userNameLabel.text = model.authorName
        self.postDateLabel.text = model.date
        self.runningDateLabel.text = "Planing to run at " + model.runningDate
        
        self.mapView.addAnnotation(self.pin)
        print("Pin added")
        

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


extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 2000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

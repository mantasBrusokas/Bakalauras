//
//  DetailedPostInfoViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-23.
//


import UIKit
import FirebaseAuth
import JGProgressHUD

class DetailedPostInfoViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    
    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "No Posts!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    } ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(noPostLabel)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPostLabel.frame = CGRect(x: 10, y: (view.height-100)/2, width: view.width-20, height: 100)
    }
    
    override func viewDidAppear(_ animeted: Bool) {
        super.viewDidAppear(animeted)
        print("Postas")

    }
    
    func createPost() {
        guard  let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 230))
        headerView.backgroundColor = .lightGray
        
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 120) / 2, y: 40, width: 120, height: 120))
        

        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        
        //userNameLabel.text = UserDefaults.standard.value(forKey: "name") as? String
        //userNameLabel.layer.frame = CGRect(x: (headerView.width - 300) / 2, y: 180, width: 300, height: 30)
        headerView.addSubview(imageView)
        //eaderView.addSubview(userNameLabel)
        
        StorageManager.shared.downloadUrl(for: path, completion: { result in
            switch result {
            case .success(let url):
                //imageView.sd_setImage(with: url, completed: nil)
                DispatchQueue.main.async {
                    imageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
            print("Failed to get download ulr: \(error)")
            }
            
        })
        return
    }
    
}

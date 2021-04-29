//
//  ViewProfileController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-29.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FBSDKLoginKit

class ViewProfileController: UIViewController {
    
    private var appUser: AppUser
    
    init(with user: AppUser) {
        self.appUser = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
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
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        return label
    } ()
    
    private var brand: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    } ()
    
    private let city: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    } ()
    
    private let bornDate: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    } ()
    
    private let gender: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    } ()
    
    private let raceDistance: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(userNameLabel)
        scrollView.addSubview(brand)
        scrollView.addSubview(city)
        scrollView.addSubview(bornDate)
        scrollView.addSubview(raceDistance)
        scrollView.addSubview(gender)
    }
    
    
    override func viewDidAppear(_ animeted: Bool) {
        super.viewDidAppear(animeted)
        validateAuth()
        print("Profilasssss")

        
        DatabaseManager.shared.getCurrentUser(currentUserEmail: appUser.emailAddress , completion: { [weak self] result in
            switch result {
            case .success(let userInfo):
                print("successfully got conversations models")
                guard !userInfo .firstName.isEmpty else {
                    print("User info empty")
                    return
                }
                self?.appUser = userInfo
                print(userInfo)
                DispatchQueue.main.async {
                    self?.brand.text = "RUNNING SHOES: " +  (self?.appUser.brand)!
                    self?.bornDate.text = "BORN DATE: " +  (self?.appUser.bornDate)!
                    self?.city.text = "CITY: " +  (self?.appUser.city)!
                    self?.gender.text = "GENDER: " + (self?.appUser.gender)!
                    self?.raceDistance.text = "RACE DISTANCE: " + (self?.appUser.distance)!
                    self?.setImage(email: (self?.appUser.emailAddress)!)
                    
                }
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
        userNameLabel.text = appUser.firstName
        
    }
    
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10,
                                     width: scrollView.width - 20, height: 30)
        city.frame = CGRect(x: 10, y: userImageView.bottom + 30,
                                     width: scrollView.width - 20, height: 30)
        bornDate.frame = CGRect(x: 10, y: city.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        brand.frame = CGRect(x: 10, y: bornDate.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        raceDistance.frame = CGRect(x: 10, y: brand.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        gender.frame = CGRect(x: 10, y: raceDistance.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        
    }
    
    public func setImage(email: String) {
        
        let path = "images/\(email)_profile_picture.png"
        
        
        print("\(email)")
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

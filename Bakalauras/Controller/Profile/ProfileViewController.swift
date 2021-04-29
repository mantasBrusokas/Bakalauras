//
//  ProfileViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-03-28.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    private var appUser: AppUser
    
    required init?(coder aDecoder: NSCoder) {
        self.appUser = AppUser(firstName: "", lastName: "", emailAddress: "", brand: "", bornDate: "", city: "", distance: "",
                               gender: "")
        super.init(coder: aDecoder)
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
    
    private let email: UILabel = {
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
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log out", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(userNameLabel)
        scrollView.addSubview(logoutButton)
        scrollView.addSubview(brand)
        scrollView.addSubview(city)
        scrollView.addSubview(bornDate)
        scrollView.addSubview(email)
        scrollView.addSubview(raceDistance)
        scrollView.addSubview(gender)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add information",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(editButtonTapped))
        logoutButton.addTarget(self,
                               action: #selector(logoutButtonTapped),
                               for: .touchUpInside)
    }
    
    
    override func viewDidAppear(_ animeted: Bool) {
        super.viewDidAppear(animeted)
        validateAuth()
        print("Profilasssss")
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        setImage(email: safeEmail)

        
        DatabaseManager.shared.getCurrentUser(currentUserEmail: safeEmail, completion: { [weak self] result in
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
                    self?.userNameLabel.text = (self?.appUser.firstName)!
                    self?.setImage(email: safeEmail)
                }
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
        self.setImage(email: safeEmail)
        self.email.text = "EMAIL: " + emailCurrentUser
    }
    
    @objc private func editButtonTapped() {
        let vc = EditProfileViewController(with: AppUser(firstName: "", lastName: "", emailAddress: "", brand: self.appUser.brand , bornDate: self.appUser.bornDate , city: self.appUser.city, distance: self.appUser.distance, gender: self.appUser.gender))
        vc.title = "Edit Profile"
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let actionSheet = UIAlertController(title: "Log out",
                                            message: "Are you sure?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                
                                                UserDefaults.standard.setValue(nil, forKey: "email")
                                                UserDefaults.standard.setValue(nil, forKey: "name")
                                                
                                                FBSDKLoginKit.LoginManager().logOut()
                                                
                                                do {
                                                    try FirebaseAuth.Auth.auth().signOut()
                                                    
                                                    let vc = LoginViewController()
                                                    let nav = UINavigationController(rootViewController: vc)
                                                    nav.modalPresentationStyle = .fullScreen
                                                    strongSelf.present(nav, animated: true)
                                                    print("User log out: \(UserDefaults.standard.value(forKey: "name") as? String ?? "Default")")
                                                }
                                                catch {
                                                    print("Failed to log out")
                                                }
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
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
        email.frame = CGRect(x: 10, y: userImageView.bottom + 30,
                                     width: scrollView.width - 20, height: 30)
        city.frame = CGRect(x: 10, y: email.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        bornDate.frame = CGRect(x: 10, y: city.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        brand.frame = CGRect(x: 10, y: bornDate.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        raceDistance.frame = CGRect(x: 10, y: brand.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        gender.frame = CGRect(x: 10, y: raceDistance.bottom + 10,
                                     width: scrollView.width - 20, height: 30)
        logoutButton.frame = CGRect(x: 40,
                                    y: scrollView.bottom - 300,
                                   width: scrollView.width-80,
                                   height: 52)
        
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

//
//  DetailedPostInfoViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-23.
//


import UIKit
import FirebaseAuth
import JGProgressHUD
import MapKit

class DetailedPostInfoViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    private let email: String
    private let postId: String
    private let postAuthorName: String
    private var conversationID: String
    private let pin = MKPointAnnotation()
    private let heightLabelOfPost: Double
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private var mapView: MKMapView = {
        let map = MKMapView()
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isUserInteractionEnabled = true
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
    
    private let sendMessageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send message", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    } ()
    
    private let runButton: UIButton = {
        let button = UIButton()
        button.setTitle("View profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    } ()
    
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
        label.textColor = .systemBlue
        return label
    }()
    
    private let postMessage: UILabel = {
        let text = UILabel()
        text.font = .systemFont(ofSize: 19, weight: .regular)
        text.numberOfLines = 0
        return text
    }()
    
    
    // Funcions!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView.frame = view.bounds
        scrollView.isUserInteractionEnabled = true
        
        view.backgroundColor = .systemBackground
        sendMessageButton.addTarget(self,
                              action: #selector(sendMessageButtonPressed),
                              for: .touchUpInside)
        runButton.addTarget(self,
                              action: #selector(viewProfile),
                              for: .touchUpInside)
        view.addSubview(scrollView)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(userNameLabel)
        scrollView.addSubview(postMessage)
        scrollView.addSubview(postDateLabel)
        scrollView.addSubview(runningDateLabel)
        scrollView.addSubview(mapView)
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        
        if safeEmail == email || safeEmail == "admin-admin-com"{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete Post", style: .plain, target: self, action: #selector(deletePost))
            navigationItem.rightBarButtonItem?.tintColor = .red
        }

        if safeEmail != email {
            scrollView.addSubview(sendMessageButton)
            scrollView.addSubview(runButton)
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnMap))
            gestureRecognizer.delegate = self
            mapView.addGestureRecognizer(gestureRecognizer)
        calculateHeight()

    }
    
    @objc private func viewProfile() {
        
        DatabaseManager.shared.getCurrentUser(currentUserEmail: email, completion: { [weak self] result in
            switch result {
            case .success(let userInfo):
                print("successfully got user")
                guard !userInfo .firstName.isEmpty else {
                    print("User info empty")
                    return
                }
                
                let vc = ViewProfileController(with: userInfo)
                
                vc.title = "Profile"
                //vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)

                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
        
    }
    
    @objc private func deletePost() {
        
        let actionSheet = UIAlertController(title: "Delete post",
                                            message: "Are you sure?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete post",
                                            style: .destructive,
                                            handler: { [weak self] _ in
                                                
                                                guard let strongSelf = self else {
                                                    return
                                                }
                                                DatabaseManager.shared.deletePost(postId: strongSelf.postId, completion: { [weak self] success in
                                                    if success {
                                                        strongSelf.navigationController?.popViewController(animated: true)
                                                        print("Post created")
                                                    } else {
                                                        print("Failed to create post...")
                                                    }
                                                })
                                            }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)

    }
    
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleTapOnMap(gestureRecognizer: UILongPressGestureRecognizer) {
        let coordinate = CLLocationCoordinate2DMake(pin.coordinate.latitude, pin.coordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = "Start Point"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 50, height: 50)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10,
                                     width: scrollView.width - 100, height: 30)
        postDateLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom,
                                     width: scrollView.width - 100, height: 15)
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        if safeEmail != email {
            sendMessageButton.frame = CGRect(x: 10, y: userImageView.bottom + 10,
                                             width: 120, height: 35)
            runButton.frame = CGRect(x: sendMessageButton.right + 10, y: userImageView.bottom + 10,
                                             width: 120, height: 35)

            runningDateLabel.frame = CGRect(x: 10, y: sendMessageButton.bottom,
                                            width: scrollView.width - 40, height: 30)
            postMessage.frame = CGRect(x: 10, y: runningDateLabel.bottom,
                                       width: scrollView.width - 20, height: self.postMessage.textRect(forBounds: CGRect(x: 0, y: 0, width: scrollView.width, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0).height)
            mapView.frame = CGRect(x: 10, y: postMessage.bottom,
                                   width: scrollView.width - 20, height: 200)
        } else {
            
        runningDateLabel.frame = CGRect(x: 10, y: userImageView.bottom + 10,
                                        width: scrollView.width - 40, height: 30)
        postMessage.frame = CGRect(x: 10, y: runningDateLabel.bottom,
                                   width: scrollView.width - 20, height: self.postMessage.textRect(forBounds: CGRect(x: 0, y: 0, width: scrollView.width, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0).height)
            mapView.frame = CGRect(x: 10, y: postMessage.bottom,
                               width: scrollView.width - 20, height: 200)
        }
        scrollView.contentSize = CGSize(width: view.width, height: mapView.frame.maxY + 370)
    }
        
    private func calculateHeight() {
        print(self.postMessage)
        let rectOfLabel = self.postMessage.textRect(forBounds: CGRect(x: 0, y: 0, width: scrollView.width, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        
        let rectOfLabelOneLine = self.postMessage.textRect(forBounds: CGRect(x: 0, y: 0, width: 100, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 1)
        let heightLabelOfPost = rectOfLabel.height
        let heightOfLine = rectOfLabelOneLine.height
        let numberOfLines = Int(heightLabelOfPost / heightOfLine)
        print(rectOfLabel)
    }
    
    override func viewDidAppear(_ animeted: Bool) {
        super.viewDidAppear(animeted)
        configure(email: email)
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        
        DatabaseManager.shared.getAllConvesations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversationsResults):
                print("successfully got conversations models")
                guard !conversationsResults.isEmpty else {
                    return
                }
                self?.conversations = conversationsResults
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
        print("Postas")
    }
    
    init(with model: Post) {
        self.postId = model.id
        self.postMessage.text = model.text.description
        self.userNameLabel.text = model.authorName
        self.postDateLabel.text = model.date
        self.runningDateLabel.text = "Planning to run at " + model.runningDate
        self.email = model.email
        self.postAuthorName = model.authorName
        self.conversationID = ""
        self.heightLabelOfPost = 0
        self.mapView.centerToLocation(model.location.location)
        pin.coordinate = model.location.location.coordinate
        pin.title = "Start Point"
        self.mapView.addAnnotation(pin)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sendMessageButtonPressed() {
        
        let currentConversations = self.conversations
        print(currentConversations)
        print()
        if let targetConversation = currentConversations.first(where: {
            $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: self.email)
            
        }) {
            print(targetConversation)
            let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
            vc.isNewconversation = false
            vc.title = targetConversation.name
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.createNewConversation(name: self.postAuthorName, email: self.email)
        }
        
    }
    
    private func createNewConversation(name: String, email: String) {
        
        // jei pridesiu pokalbio istrynimo galimybe cia reikes apsirasyt tvarkyma, kad nekurtu duplicate
        
        let vc = ChatViewController(with: email, id: nil)
        print(email)
        vc.isNewconversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    public func configure(email: String) {
        
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
                let url1 = URL(string: "https://firebasestorage.googleapis.com/v0/b/findarunningpartner-998ed.appspot.com/o/images%2Fno-avatar.png?alt=media&token=b3967fae-d169-4fdb-a123-341c8ea645d0")
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url1, completed: nil)
                }
            }
            
        })
    }
    
}

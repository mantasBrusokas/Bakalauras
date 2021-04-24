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
    private var conversations = [Conversation]()
    private let email: String
    private let postAuthorName: String
    private var conversationID: String
    
    
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
    
    private let sendMessageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send message", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        //button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
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
        label.textColor = .systemGreen
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
        view.backgroundColor = .systemBackground
        sendMessageButton.addTarget(self,
                              action: #selector(sendMessageButtonPressed),
                              for: .touchUpInside)
        view.addSubview(scrollView)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(userNameLabel)
        scrollView.addSubview(postMessage)
        scrollView.addSubview(postDateLabel)
        scrollView.addSubview(runningDateLabel)
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        
        if safeEmail != email {
            scrollView.addSubview(sendMessageButton)
        }


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10,
                                     width: 50, height: 50)
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10,
                                     width: scrollView.width - 100, height: 30)
        postDateLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom,
                                     width: scrollView.width - 100, height: 15)
        sendMessageButton.frame = CGRect(x: 10, y: userImageView.bottom + 10,
                                         width: 150, height: 40)
        runningDateLabel.frame = CGRect(x: 10, y: sendMessageButton.bottom,
                                        width: scrollView.width - 100, height: 30)
        postMessage.frame = CGRect(x: 10, y: runningDateLabel.bottom,
                                   width: scrollView.width - 20, height: 100)
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
        self.postMessage.text = model.text.description
        self.userNameLabel.text = model.authorName
        self.postDateLabel.text = model.date
        self.runningDateLabel.text = "Planing to run at " + model.runningDate
        self.email = model.email
        self.postAuthorName = model.authorName
        self.conversationID = ""
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getCurrentConversations() {
        
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


//
//  ViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-03-28.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Post {
    let id: String
    let authorName: String
    let email: String
    let date: String
    let text: String
    let read: Bool
    
}


class PostsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var posts = [Post]()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = false
        table.register(PostTableViewCell.self,
                       forCellReuseIdentifier: PostTableViewCell.indetifier)
        return table
    }()
    
    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "No Posts!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    } ()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noPostLabel)
        setupTableView()
        startListeningForPosts()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startListeningForPosts()
        })
    }
    
    private func startListeningForPosts() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        print("starting conversations fetch.....")
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllPosts(completion: { [weak self] result in
            switch result {
            case .success(let posts):
                print("successfully got posts models")
                guard !posts.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noPostLabel.isHidden = false
                    return
                }
                self?.noPostLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.posts = posts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
            print("failed to get conversations: \(error)")
                self?.tableView.isHidden = true
                self?.noPostLabel.isHidden = false
            
            }
        })
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewPostViewController()

        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noPostLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2, width: view.width-20, height: 100)
    }
    
    override func viewDidAppear(_ animeted: Bool) {
        super.viewDidAppear(animeted)
            
            validateAuth()
        
        }
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: false)
    }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.indetifier,
                                                 for: indexPath) as! PostTableViewCell
        cell.configure(with: model)
        
        return cell
    }
    
    
/*    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = posts[indexPath.row]
        //openConversation(model)
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title =  model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    
}

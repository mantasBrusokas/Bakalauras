
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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

   
}

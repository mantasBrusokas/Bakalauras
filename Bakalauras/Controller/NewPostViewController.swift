//
//  NewPostViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-22.
//

import UIKit
import FirebaseAuth

class NewPostViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let postButton: UIButton = {
        let button = UIButton()
        button.setTitle("Post", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        //button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    } ()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"Write something...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.textColor = .black
        return field
    }()
    
    private let date: UIDatePicker = {
        let field = UIDatePicker()
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        
        postButton.addTarget(self,
                                 action: #selector(postButtonTapped),
                                 for: .touchUpInside)
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(textField)
        scrollView.addSubview(date)
        scrollView.addSubview(postButton)
        
        scrollView.isUserInteractionEnabled = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
      
        textField.frame = CGRect(x: 5,
                                      y: 5,
                                      width: scrollView.width-10,
                                      height: 100)
        date.frame = CGRect(x: 100,
                            y: textField.bottom + 10,
                                     width: scrollView.width-60,
                                     height: 52)
     
        postButton.frame = CGRect(x: 30,
                                      y: date.bottom + 10,
                                      width: scrollView.width-60,
                                      height: 52)
    }
    
    @objc private func postButtonTapped() {
        
        textField.resignFirstResponder()
        date.resignFirstResponder()
        
        DatabaseManager.shared.createNewPost(post: Post(id: "testinis", authorName: "test", email: "alio", date: "sda", text: "Naujausias postas!!", read: false), completion: {_ in })
        
        dismissSelf()
    }
    
   
}

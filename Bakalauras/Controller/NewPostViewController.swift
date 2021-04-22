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
    
    private let textField: UITextView = {
        let field = UITextView()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .secondarySystemBackground
        field.font = UIFont.systemFont(ofSize: 17)
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
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 10, y: 0, width: 100, height: navigationBar.frame.height)
            let firstLabel = UILabel(frame: firstFrame)
            firstLabel.text = "New Post:"
            firstLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            navigationBar.addSubview(firstLabel)
        }
        
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
                                      height: 80)
        date.frame = CGRect(x: (scrollView.width - date.width) / 2,
                            y: textField.bottom + 10,
                            width: date.width,
                                     height: 52)
     
        postButton.frame = CGRect(x: 30,
                                      y: date.bottom + 10,
                                      width: scrollView.width-60,
                                      height: 52)
    }
    
    func alertPostError(message: String = "Please enter all information to create a new post :) ") {
        let alert = UIAlertController(title: "Oops",
                                      message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    private func createPostId() -> String? {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String
        else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Date()
        let newIdetifier = "\(safeCurrentEmail)_\(dateString)"
        return newIdetifier
    }
    
    private func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, h:mm a"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    private func formatDatePickerToString(date: UIDatePicker) -> String {
        let datePickerDate = date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, h:mm a"
        let dateString = formatter.string(from: datePickerDate.date)
        return dateString
    }
    
    
    @objc private func postButtonTapped() {
        
        textField.resignFirstResponder()
        date.resignFirstResponder()
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentUserName = UserDefaults.standard.value(forKey: "name") as? String
        else {
            return
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        guard let text = textField.text,
              !text.isEmpty else {
            alertPostError(message: "Description is empty")
            return
        }
        guard let postId = createPostId() else {
            return
        }
        
        
        DatabaseManager.shared.createNewPost(post: Post(id: postId, authorName: currentUserName, email: safeCurrentEmail, date: getCurrentDate(), text: text, read: false, runningDate: formatDatePickerToString(date: date)), completion: { [weak self] success in
            if success {
                self?.dismissSelf()
                print("Post created")
            } else {
                print("Failed to create post...")
            }
        })


        
        
    }
    
   
}

//
//  NewPostViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-22.
//

import UIKit
import FirebaseAuth
import CoreLocation
import MessageKit


struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

class NewPostViewController: UIViewController {
    
    private var location: Location = {
        Location(location: CLLocation(latitude: 0, longitude: 0),
                                 size: .zero)
    } ()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let addRouteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Starting Point", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
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
        field.textColor = .systemBlue
        return field
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Set running time"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
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
        
        textField.text = "Write something about your planning run: pace, distance, time, etc..."
        textField.textColor = .lightGray
        
        addRouteButton.addTarget(self, action: #selector(presentLocationPicker),
                                 for: .touchUpInside)
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(textField)
        scrollView.addSubview(date)
        scrollView.addSubview(addRouteButton)
        scrollView.addSubview(dateLabel)
        setupTextView()
        scrollView.isUserInteractionEnabled = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postButtonTapped))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupTextView() {
        textField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
      
        textField.frame = CGRect(x: 20,
                                      y: 20,
                                      width: scrollView.width-40,
                                      height: 120)
        dateLabel.frame = CGRect(x: date.left - 140,
                            y: textField.bottom + 20,
                            width: 140,
                                     height: 52)
        date.frame = CGRect(x: (scrollView.width - date.width + 140) / 2,
                            y: textField.bottom + 20,
                            width: date.width,
                                     height: 52)
        addRouteButton.frame = CGRect(x: 30,
                                      y: date.bottom + 20,
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
            print("Email or name nil")
            return
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        guard let text = textField.text,
              !text.isEmpty else {
            alertPostError(message: "Description is empty")
            return
        }
        guard let dateCheck = formatDatePickerToString(date: date) as? String,
              getCurrentDate() <= dateCheck  else {
            alertPostError(message: "Date is not valid")
            return
        }
        guard let postId = createPostId() else {
            return
        }
        guard self.location.location.coordinate.latitude.binade != 0, self.location.location.coordinate.longitude.binade != 0  else {
            alertPostError(message: "You must select a starting point!")
            return
        }
        
        DatabaseManager.shared.createNewPost(post: Post(id: postId, authorName: currentUserName, email: safeCurrentEmail, date: getCurrentDate(), text: text, read: false, runningDate: formatDatePickerToString(date: date), location: self.location), completion: { [weak self] success in
            if success {
                self?.dismissSelf()
                print("Post created")
            } else {
                print("Failed to create post...")
            }
        })
        
    }
    
    
    func alert(message: String) {
        let alert = UIAlertController(title: "",
                                      message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
            alert.dismiss(animated: true, completion: nil)}
    }

    
    @objc private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { selectedCoorindates in
            
            print("long=\(selectedCoorindates.longitude) | lat= \(selectedCoorindates.latitude)")
            
            
            self.location = Location(location: CLLocation(latitude: selectedCoorindates.latitude, longitude: selectedCoorindates.longitude),
                                     size: .zero)
            
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NewPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    /*
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write something about your planning run: pace, distance, time, etc..."
            textView.textColor = .lightGray
        }
    } */
}

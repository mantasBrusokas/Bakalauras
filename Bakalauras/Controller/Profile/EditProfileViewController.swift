//
//  EditProfileViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-28.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FBSDKLoginKit

class EditProfileViewController: UIViewController {
    
    var arrayGender = [String]()
    private var changed = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private var brandLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Running shoes: "
        return label
    } ()
    
    private var bornDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Born date: "
        return label
    } ()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "City: "
        return label
    } ()
    
    private let raceDistanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.text = "Race distance: "
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let runningShoes: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"Add running shoes...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.textColor = .systemBlue
        return field
    }()
    
    private let raceDistance: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"Race distance...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.textColor = .systemBlue
        return field
    }()
    
    private let city: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"City", attributes:[NSAttributedString.Key.foregroundColor: UIColor.black])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.textColor = .systemBlue
        return field
    }()
    
    private let bornDate: UIDatePicker = {
        let field = UIDatePicker()
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .secondarySystemBackground
        field.datePickerMode = .date
        return field
    }()
    
    private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private var gender: UILabel = {
        let gender = UILabel()
        return gender
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(bornDate)
        scrollView.addSubview(runningShoes)
        scrollView.addSubview(city)
        scrollView.addSubview(pickerView)
        scrollView.addSubview(raceDistance)
        scrollView.addSubview(cityLabel)
        scrollView.addSubview(brandLabel)
        scrollView.addSubview(raceDistanceLabel)
        scrollView.addSubview(bornDateLabel)
        arrayGender = ["", "Male","Female","Other"]
         self.pickerView.dataSource = self
         self.pickerView.delegate = self
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        setImage(email: safeEmail)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateButtonTapped))
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePicture))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        
        runningShoes.frame = CGRect(x: brandLabel.right + 5,
                                      y: imageView.bottom + 40,
                                      width: scrollView.width-(brandLabel.right + 20),
                                      height: 52)
        raceDistance.frame = CGRect(x: raceDistanceLabel.right + 5,
                                   y: runningShoes.bottom + 10,
                                   width: scrollView.width - raceDistanceLabel.right - 20,
                                   height: 52)
        city.frame = CGRect(x: cityLabel.right + 5,
                                     y: raceDistance.bottom + 10,
                                     width: scrollView.width-cityLabel.right - 20,
                                     height: 52)
        brandLabel.frame = CGRect(x: 20,
                                      y: imageView.bottom + 40,
                                      width: 155,
                                      height: 52)
        raceDistanceLabel.frame = CGRect(x: 20,
                                   y: runningShoes.bottom + 10,
                                   width: 148,
                                   height: 52)
        cityLabel.frame = CGRect(x: 20,
                                     y: raceDistance.bottom + 10,
                                     width: 50,
                                     height: 52)
        pickerView.frame = CGRect(x: 20,
                                  y: city.bottom + 10,
                                  width: scrollView.width-40,
                                  height: 100)
        bornDateLabel.frame = CGRect(x: 20,
                                  y: pickerView.bottom + 10,
                                  width: 120,
                                  height: 52)
        bornDate.frame = CGRect(x: bornDateLabel.right + 5,
                                  y: pickerView.bottom + 10,
                                  width: 135,
                                  height: 52)

    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc private func updateButtonTapped() {
        guard let emailCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailCurrentUser)
        let dateCheck = formatDatePickerToString(date: bornDate)
        
        DatabaseManager.shared.updateUser(safeEmail: safeEmail, newUserInfo: AppUser(firstName: "", lastName: "", emailAddress: safeEmail,
                                                                                     brand: runningShoes.text ?? "", bornDate: dateCheck , city: city.text ?? "", distance: raceDistance.text ?? "", gender: gender.text ?? ""),
                                          completion: { [weak self] success in
            if success {
                DispatchQueue.main.async {
                // upload image
                guard let image = self?.imageView.image, let data = image.pngData() else {
                    return
                }
                    if self?.changed == true {
                        let filename = "\(safeEmail)_profile_picture.png"
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                                
                            }
                        })
                    } else {
                        return
                    }
                    
                }
                self?.dismissSelf()
                print("Profile updated")
            } else {
                print("Failed to update profile...")
            }
        })
    }
    
    init(with user: AppUser) {
        self.city.text = user.city
        self.runningShoes.text = user.brand
        self.gender.text = user.gender
        self.raceDistance.text = user.distance
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.dateStyle = .short
        self.bornDate.date = dateFormatter.date(from: user.bornDate) ?? dateFormatter.date(from: "02/10/2010")!
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func formatDatePickerToString(date: UIDatePicker) -> String {
        let datePickerDate = date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        let dateString = formatter.string(from: datePickerDate.date)
        return dateString
    }
    
    public func setImage(email: String) {
        
        let path = "images/\(email)_profile_picture.png"
        
        
        print("\(email)")
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            
            case .success(let url):
                DispatchQueue.main.async {
                    self?.imageView.sd_setImage(with: url, completed: nil)
                    
                }
                
            case .failure(let error):
                print("failed to get image url: \(error)")
            }
            
        })
    }
    
}


extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile picture",
                                            message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil ))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                
                                                self?.presentCamera()
                                            } ))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: {[weak self] _ in
                                                
                                                self?.presentPhotoPicker()
                                            } ))
        
        present(actionSheet, animated: true)
    }
    
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        changed = true
    }
    
    func  imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    //MARK: - Pickerview method
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return arrayGender.count
   }
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       return arrayGender[row]
   }
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       self.gender.text = arrayGender[row]
   }

}

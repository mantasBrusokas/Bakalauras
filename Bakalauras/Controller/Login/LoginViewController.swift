//
//  LoginViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-03-28.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import JGProgressHUD

class LoginViewController: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"Email Address...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string:"Password...", attributes:[NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    } ()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setTitle("Reset Password", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        return button
    } ()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Log in"
        emailField.isHidden = true
        passwordField.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        resetPasswordButton.addTarget(self,
                              action: #selector(resetPasswordButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(resetPasswordButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        

        let size = scrollView.width/1.5
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 40,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width-80,
                                  height: 52)

        passwordField.frame = CGRect(x: 40,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width-80,
                                     height: 52)
        resetPasswordButton.frame = CGRect(x: 80,
                                       y: passwordField.bottom + 10,
                                       width: scrollView.width-160,
                                       height: 30)

        loginButton.frame = CGRect(x: 40,
                                   y: resetPasswordButton.bottom + 10,
                                   width: scrollView.width-80,
                                   height: 52)
        facebookLoginButton.frame = CGRect(x: 40,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width-80,
                                           height: 52)
    }
    
    @objc private func resetPasswordButtonTapped() {
        let emailValue = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if emailField.isHidden == true {
            setView(view: emailField, hidden: false)
        } else {
            emailField.resignFirstResponder()
            print(emailValue)
            Auth.auth().sendPasswordReset(withEmail: emailValue!, completion: { error in
                if error != nil {
                    print(error!)
                    self.alertUserLoginError(message: "User do not exist or email field is empty")
                }
                else {
                    self.alertUserLogin(message: "Password reset \n Check your email!")
                    return
                }
                
            })
        }
    }
    
    @objc private func loginButtonTapped() {
        UserDefaults.standard.setValue(nil, forKey: "email")
        UserDefaults.standard.setValue(nil, forKey: "name")
        
        if emailField.isHidden == false && passwordField.isHidden == false {
            
            
            emailField.resignFirstResponder()
            passwordField.resignFirstResponder()
            
            guard let email = emailField.text,
                  !email.isEmpty else {
                alertUserLoginError(message: "Please enter the email")
                return
            }
            
            guard let password = passwordField.text,
                  !password.isEmpty, password.count >= 6 else {
                alertUserLoginError(message: "Please enter the password")
                return
            }
            
            spinner.show(in: view)
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()
                }
                
                
                guard let result = authResult, error == nil else {
                    print("Failed to login user with email: \(email)")
                    strongSelf.alertUserLoginError(message: "Loggin information is not correct")
                    strongSelf.resetPasswordButton.isHidden = false
                    return
                }
                let user = result.user
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String: Any],
                        let name = userData["name"] as? String else {
                            return
                        }
                        UserDefaults.standard.set("\(name)", forKey: "name")
                    case .failure(let error):
                        print("Failed to read data with error: \(error)")
                    }
                })
                
                UserDefaults.standard.set(email, forKey: "email")

                
                print("Logged in user: \(user)")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
            // Firebase Log in
        }
        setView(view: emailField, hidden: false)
        setView(view: passwordField, hidden: false)
    }
    
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Oops",
                                      message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    func alertUserLogin(message: String) {
        let alert = UIAlertController(title: "",
                                      message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
            alert.dismiss(animated: true, completion: nil)}
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
            
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no opration
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("User failed to login with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completionHandler: { _, result, error in
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make FB request")
                return
            }
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                print("Failed tp get email and name from fb")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = AppUser(firstName: firstName, lastName: lastName, emailAddress: email, brand: "", bornDate: "", city: "", distance: "", gender: "")
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Dowloanding data from fb image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data,
                                                                                       _, _ in
                                guard let data = data else {
                                    print("Failed tp get data from facebook")
                                    return
                                }
                                
                                print("got data from FB, uploading")
                                
                                // upload image
                                let filename = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                    }
                                })
                            }).resume()
                        }
                        
                    })
                }
                
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed -\(error)")
                    }
                    return
                }
                print("Successfully logged user in: \(email)")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
        
        
        
    }
    
}

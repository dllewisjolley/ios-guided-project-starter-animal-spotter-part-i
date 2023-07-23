//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 BloomTech. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signInButton: UIButton!
    
    var apiController: APIController?
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
        signInButton.tintColor = .white
        signInButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Action Handlers
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // perform login or sign up operation based on loginType
        if let userName = usernameTextField.text,
           !userName.isEmpty,
           let password = passwordTextField.text,
           !password.isEmpty {
            let user = User(userName: userName, password: password)
            
            switch loginType {
            case .signUp:
                apiController?.signUp(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign up was successful", message: "Please Sign in!", preferredStyle: .alert)
                                
                                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                                alertController.addAction(alertAction)
                                
                                self.present(alertController, animated: true) {
                                    self.loginType = .signIn
                                    self.signInButton.setTitle("Sign In", for: .normal)
                                    self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                                    
                                }
                                
                            }
                        }
                    } catch {
                        print("Error signing up: \(error)")
                    }
                })
            case .signIn:
                apiController?.signIn(with: user, completion: { result in
                    do {
                        let success = try result.get()
                        if success {
                            
                            DispatchQueue.main.async {
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                        }
                    } catch {
                        if let error = error as? APIController.NetworkError {
                            switch error {
                            case .failedSignIn:
                                print("sign in failed")
                            case .failedSignUp:
                                print("failed sign up")
                                
                            case .noData:
                                print("no data recieved")
                                
                            case .noToken:
                                print("no token reviecved")
                                
                            }
                        }
                        
                    }
                })
            }
        }
        
    }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        // switch UI between login types
        
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
}

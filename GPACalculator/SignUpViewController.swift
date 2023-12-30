//
//  SignUpViewController.swift
//  Final_Exam
//
//  Created by Gregory Hagins II on 5/6/20.
//  Copyright © 2020 Gregory Hagins II. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class SignUpViewController: UIViewController {
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var submitOutlet: UIButton!
    @IBOutlet weak var cancelOutlet: UIButton!
    
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = .systemPurple
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicator)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter a Valid Email.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter a Valid Password.")
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter a Confirmed Password.")
            return
        }
        
        if password != confirmPassword {
            displayAlert(title: "Error", message: "Please Enter a Validated Password.")
            return
        }
        
        createUser(email: email, password: password) { userCreated in
            switch userCreated {
            case true:
                LoginViewController().signIn(email: email, password: password) { userSignedIn in
                    switch userSignedIn {
                    case true:
                        NotificationCenter.default.post(name: Notification.Name("LoadTableFromSignUp"), object: nil)
                        self.performSegue(withIdentifier: "SignUpToGPA", sender: self)
                    case false:
                        print("User not signed in")
                    }
                }
            case false:
                print("User not created")
            }
        }
    }
    
    
    func hideUIElements(hideFlag: Bool) {
        self.submitOutlet.isHidden = hideFlag
        self.cancelOutlet.isHidden = hideFlag
    }
    
    func createUser(email: String, password: String, finished: @escaping (_ done: Bool) -> Void) {
        finished(false)
        self.activityIndicator.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.hideUIElements(hideFlag: true)
                finished(true)
                
                print("Account Creation Success")
            }
            else {
                self.activityIndicator.stopAnimating()
                self.hideUIElements(hideFlag: false)
                
                if let error = error {
                    self.displayAlert(title: "Error", message: error.localizedDescription)
                }
                
                finished(false)
            }
        }
        
  
//        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//            if error == nil {
//                self.activityIndicator.startAnimating()
//                self.submitOutlet.isHidden = true
//                self.cancelOutlet.isHidden = true
//                
//                print("Account Creation Success")
//                
//                
//                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
//                    if error == nil {
//                        NotificationCenter.default.post(name: Notification.Name("LoadTableFromSignUp"), object: nil)
//                        
//                        Timer.scheduledTimer(withTimeInterval: 0.50, repeats: false) { (timer) in
//                            self.activityIndicator.stopAnimating()
//                            self.performSegue(withIdentifier: "SignUpToGPA", sender: self)
//                        }
//                        
//                    }
//                }
//                
//            }
//            
//        }
        

    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        self.ref.child("User").child(Auth.auth().currentUser!.uid).setValue(String((Auth.auth().currentUser?.email)!))
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Dismisses keyboard when return in tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}

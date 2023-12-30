//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var navigationBarOutlet: UINavigationItem!
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    
    @IBOutlet weak var submitButtonOutlet: UIButton!
    @IBOutlet weak var createAccountButtonOutlet: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref:DatabaseReference = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismisses keyboard on tap outside of the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(logOut(notification:)), name: Notification.Name("LogOut"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = .systemPurple
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicator)
        
        isUserSignedIn { signedIn in
            switch signedIn {
            case true:
                self.performSegue(withIdentifier: "GPAPage", sender: self)
            case false:
                print("No User is Signed In")
            }
        }
    }
    
    @IBAction func submitLoginCreds(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter a Valid Email")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter A Valid Password")
            return
        }
        
        signIn(email: email, password: password) { signInCompleted in
            switch signInCompleted {
            case true:
                self.performSegue(withIdentifier: "GPAPage", sender: self)
                
            case false:
                print("Error Signing In.")
            }
        }
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        //        global.notificationHandler()
        self.performSegue(withIdentifier: "CreateAccount", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    func isUserSignedIn(finished: @escaping (_ done: Bool) -> Void) {
        self.activityIndicator.startAnimating()
        hideUIComponents(hideFlag: true)
        finished(false)
        
        if Auth.auth().currentUser != nil {
            self.activityIndicator.stopAnimating()
            finished(true)
        }
        else {
            self.activityIndicator.stopAnimating()
            hideUIComponents(hideFlag: false)
            finished(false)
        }
    }
    
    func signIn(email: String, password: String, finished: @escaping (_ done: Bool) -> Void) {
        self.activityIndicator.startAnimating()
        finished(false)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error == nil {
                self.activityIndicator.stopAnimating()
                print("User Signed In")
                finished(true)
            } 
            else {
                self.activityIndicator.stopAnimating()
                self.displayAlert(title: "Error", message: "\(String(error!.localizedDescription))")
                print(error!.localizedDescription)
                finished(false)
            }
        }
    }
    
    func removeUser() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        Database.database().reference().child("User").child(currentUser.uid).removeValue { (error, ref) in
            if error != nil {
                print("Failed to Delete User")
            }
            else {
                print("User Removed")
            }
        }
    }
    
    @objc func logOut(notification: Notification) {
        removeUser()
        
        do {
            try Auth.auth().signOut()
            print("user signed out")
        } catch let signOutError as NSError {
            print("Error signing out: %@: ", signOutError)
        }
        emailTextField.text = nil
        passwordTextField.text = nil
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
    
    func hideUIComponents(hideFlag: Bool) {
        self.navigationController?.setNavigationBarHidden(hideFlag, animated: true)
        emailTextField.isHidden = hideFlag
        emailLabelOutlet.isHidden = hideFlag
        passwordTextField.isHidden = hideFlag
        passwordLabelOutlet.isHidden = hideFlag
        submitButtonOutlet.isHidden = hideFlag
        createAccountButtonOutlet.isHidden = hideFlag
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}

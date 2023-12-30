//
//  NewCourseViewController.swift
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

class NewCourseViewController: UIViewController {
    
    var ref:DatabaseReference = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var creditHourTextField: UITextField!
    @IBOutlet weak var gradeSegmentControl: UISegmentedControl!
    
    let gradeDict = [0: "A", 1: "B", 2: "C", 3: "D", 4: "F"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismisses keyboard on tap outside of the screen
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
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        guard let courseNumber = numberTextField.text, !courseNumber.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter A Valid Course Number!")
            return
        }
        
        guard let courseName = nameTextField.text, !courseName.isEmpty else {
            displayAlert(title: "Error", message: "Please Enter A Valid Course Name!")
            return
        }
        guard let creditHours = creditHourTextField.text, !creditHours.isEmpty, Double(creditHours)! > 0.0, Double(creditHours)! <= 3.0 else {
            displayAlert(title: "Error", message: "Please Enter A Valid Course Credit Hour!")
            return
        }
        
        guard let grade = gradeDict[gradeSegmentControl.selectedSegmentIndex] else {
            displayAlert(title: "Error", message: "Please Enter A Valid Letter Grade!")
            return
        }
        
        setCourse(courseName: courseName, courseNumber: courseNumber, creditHours: creditHours as String, grade: grade) { dataSet in
            switch dataSet {
            case true:
                self.dismiss(animated: true)
                
            case false:
                print("Waiting to Set New Course Information")
            }
        }
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
    
    func setCourse(courseName: String, courseNumber: String, creditHours: String, grade: String, finished: @escaping (_ done: Bool) -> Void) {
        self.activityIndicator.startAnimating()
        finished(false)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        self.ref.child("Grades").child(currentUser.uid).childByAutoId().setValue([
                "number": courseNumber,
                "name": courseName,
                "crhr": creditHours,
                "grade": grade
            ])
        
        self.activityIndicator.stopAnimating()
        finished(true)
    }
    
}

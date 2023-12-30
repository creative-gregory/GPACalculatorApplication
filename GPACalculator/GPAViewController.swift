//
//  GPAViewController.swift
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

class Course {
    var name:String?
    var number:String?
    var grade:String?
    var creditHour:String?
    var id:String?
    
    init(name: String, number: String, grade: String, creditHour: String, id: String) {
        self.name = name
        self.number = number
        self.grade = grade
        self.creditHour = creditHour
        self.id = id
    }
}

class GPAViewController: UIViewController {

    var grades = [Course]()
    
    var ref:DatabaseReference = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var gpaLabel: UILabel!
    @IBOutlet weak var courseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "CourseTableViewCell", bundle: nil)
        courseTableView.register(cellNib, forCellReuseIdentifier: "CourseCell")
        
        guard let currentUser = Auth.auth().currentUser else { return }
        self.ref.child("User").child(currentUser.uid).setValue(currentUser.uid)
        
        getGrades { gradesObtained in
            switch gradesObtained {
            case true:
                print("Grade Information Obtained")

            case false:
                print("Obtaining Grade Information")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.color = .systemPurple
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.addSubview(activityIndicator)
    }
    
    @IBAction func addNewGrade(_ sender: Any) {
        self.performSegue(withIdentifier: "NewGrade", sender: self)
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        signOut { signedOut in
            switch signedOut {
            case true:
                self.dismiss(animated: true)
                
            case false:
                print("Sending Notification to Sign User Out")
            }
        }
    }
    
    func signOut(finished: @escaping (_ done: Bool) -> Void) {
        self.activityIndicator.startAnimating()
        finished(false)
        
        NotificationCenter.default.post(name: Notification.Name("LogOut"), object: nil)
        
        self.activityIndicator.stopAnimating()
        finished(true)
    }

    func getGrades(finished: @escaping (_ done: Bool) -> Void) {
        self.activityIndicator.startAnimating()
        finished(false)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ref.child("Grades").child(currentUser.uid).observe(.value) { (snapshot) in
            self.grades.removeAll()
            
            var creditHours:Double = 0.0
            var gradePoints:Double = 0.0
            
            if snapshot.exists() {
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot else { return }
                    guard let courseData = childSnapshot.value as? [String:String] else { return }
                    
                    guard let grade  = courseData["grade"]  else { return }
                    guard let crhr   = courseData["crhr"]   else { return }
                    guard let name   = courseData["name"]   else { return }
                    guard let number = courseData["number"] else { return }
                                        
                    self.grades.append(Course(name: name, number: number, grade: grade, creditHour: crhr, id: childSnapshot.key))
                    
//                    print(childSnapshot.key)
                    
                    switch grade {
                    case "A":
                        gradePoints = gradePoints + (Double(crhr)! * 4)
                        
                    case "B":
                        gradePoints = gradePoints + (Double(crhr)! * 3)
                        
                    case "C":
                        gradePoints = gradePoints + (Double(crhr)! * 2)
                        
                    case "D":
                        gradePoints = gradePoints + (Double(crhr)! * 1)
                        
                    case "F":
                        gradePoints = gradePoints + (Double(crhr)! * 0)
                        
                    default:
                        break
                    }
                    
                    creditHours = creditHours + Double(crhr)!
                    
                    print(gradePoints)
                    print(creditHours)
                }
                self.gpaLabel.text = "GPA: " + String(format: "%0.2f", gradePoints/creditHours)
                self.hoursLabel.text = "Hours: " + String(format: "%0.2f", creditHours)
                
                finished(true)
                self.activityIndicator.stopAnimating()
            }
            else {
                self.gpaLabel.text = "GPA: 0.00"
                self.hoursLabel.text = "Hours: 0.00"
                finished(false)
                
                print("No Course Information Available")
                self.activityIndicator.stopAnimating()
            }
            
            self.courseTableView.reloadData()
        }
    }
    
    func deleteCourse(course: Course, finished: @escaping (_ done: Bool) -> Void) {
        finished(false)
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let courseID = course.id else { return }
        
        Database.database().reference().child("Grades").child(currentUser.uid).child("\(courseID)").removeValue { (error, ref) in
            if error == nil {
                print("Course Removed from Database")
                finished(true)
            }
            else {
                print("Failed to Remove Course from Database")
                
                if let error = error {
                    self.displayAlert(title: "Error", message: "Failed to Delete Course: \(error.localizedDescription)")
                }
                finished(false)
            }
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}

extension GPAViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = courseTableView.dequeueReusableCell(withIdentifier: "CourseCell") as! CourseTableViewCell
        
        cell.delegate = self as CourseCellDelegate
        
        if let courseName = grades[indexPath.row].name { cell.nameLabel.text = courseName }
        if let courseNumber = grades[indexPath.row].number { cell.numberLabel.text = courseNumber }
        if let creditHours = grades[indexPath.row].creditHour { cell.crLabel.text = "Credit Hours: \(creditHours)" }
        if let grade = grades[indexPath.row].grade  { cell.gradeLabel.text = grade }
        
        return cell
    }
}

extension GPAViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GPAViewController: CourseCellDelegate {
    func deleteButton(cell: UITableViewCell) {
        let indexPath = self.courseTableView.indexPath(for: cell)
        guard let indexPath = indexPath else { return }
        guard let courseName = self.grades[indexPath.row].name else { return }
        
        deleteCourse(course: grades[indexPath.row]) { gradeDeleted in
            switch gradeDeleted {
            case true:
                print("Deleted data for course: \(courseName)")
                
            case false:
                print("Failed to delete data for course: \(courseName)")
            }
        }
        
        getGrades { gradesObtained in
            switch gradesObtained {
            case true:
                print("Grade Information Obtained")
                
            case false:
                print("Obtaining Grade Information")
            }
        }
    }
}

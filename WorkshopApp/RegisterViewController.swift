//
//  RegisterViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/22/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class RegisterViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    //var currentLocation: CLLocation!
    var currLon: Double = -1
    var currLat: Double = -1
    
    @IBOutlet weak var userButtonOutlet: UIButton!
    @IBOutlet weak var handymanButtonOutlet: UIButton!
    @IBOutlet weak var orLabelOutlet: UILabel!
    
    @IBOutlet weak var emailFieldOutlet: UITextField!
    @IBOutlet weak var passwordFieldOutlet: UITextField!
    
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var telNumLabel: UITextField!
    
    @IBOutlet weak var handymenLabel: UILabel!
    @IBOutlet weak var electricianButtonOutlet: UIButton!
    @IBOutlet weak var plumberButtonOutlet: UIButton!
    @IBOutlet weak var mechanicButtonOutlet: UIButton!
    
    var userType: Int = -1 //1->user 2->handyman
    var handymanType: String = "" //variable for handymanType
    
    override func viewDidLoad(){
        super.viewDidLoad()
        handymenLabel.isHidden = true
        electricianButtonOutlet.isHidden = true
        plumberButtonOutlet.isHidden = true
        mechanicButtonOutlet.isHidden = true
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        /*if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
            currentLocation = locationManager.location
        }*/
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        currLat = locValue.latitude
        currLon = locValue.longitude
    }
    

    @IBAction func userButton(_ sender: Any) {
        userType = 1  //user chosen
        userButtonOutlet.isHidden = true
        handymanButtonOutlet.isHidden = true
        orLabelOutlet.text = "User chosen"
    }
    
    @IBAction func handymenButton(_ sender: Any) {
        userType = 2 //handyman chosen
        userButtonOutlet.isHidden = true
        handymanButtonOutlet.isHidden = true
        orLabelOutlet.text = "Handyman chosen"
        
        if handymenLabel.isHidden == true && electricianButtonOutlet.isHidden == true && plumberButtonOutlet.isHidden == true && mechanicButtonOutlet.isHidden == true{
            handymenLabel.isHidden = false
            electricianButtonOutlet.isHidden = false
            plumberButtonOutlet.isHidden = false
            mechanicButtonOutlet.isHidden = false
        }
    }
    
    
    @IBAction func electricianChosen(_ sender: Any) {
        if handymanType == ""{
            handymanType = "Electrician"
        }
        if plumberButtonOutlet.isHidden == false && mechanicButtonOutlet.isHidden == false{
            plumberButtonOutlet.isHidden = true
            mechanicButtonOutlet.isHidden = true
        }
    }
    
    @IBAction func plumberChosen(_ sender: Any) {
        if handymanType == ""{
            handymanType = "Plumber"
        }
        if electricianButtonOutlet.isHidden == false && mechanicButtonOutlet.isHidden == false{
            electricianButtonOutlet.isHidden = true
            mechanicButtonOutlet.isHidden = true
        }
    }
    
    @IBAction func mechanicChosen(_ sender: Any) {
        if handymanType == ""{
            handymanType = "Mechanic"
        }
        if electricianButtonOutlet.isHidden == false && plumberButtonOutlet.isHidden == false{
            electricianButtonOutlet.isHidden = true
            plumberButtonOutlet.isHidden = true
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let user = PFUser()
        if emailFieldOutlet.text == "" || passwordFieldOutlet.text == "" || firstNameLabel.text == "" || lastNameLabel.text == "" || telNumLabel.text == ""
        {
            displayAlert(title: "Sign Up Error", message: "All information must be provided")
        }else{
            user.username = emailFieldOutlet.text
            user.password = passwordFieldOutlet.text
            user.email = emailFieldOutlet.text
            user["firstName"] = firstNameLabel.text
            user["lastName"] = lastNameLabel.text
            user["phone"] = telNumLabel.text
            
            
            if userType != -1 && userType == 1{
                //user
                user["displayName"] = "User"
            }else if userType != -1 && userType == 2{
                //majstor
                user["displayName"] = "Handyman"
                
                user["lat"] = currLat
                user["lon"] = currLon
                
                if handymanType == "Electrician"{
                    user["handymanType"] = "Electrician"
                }else if handymanType == "Plumber"{
                    user["handymanType"] = "Plumber"
                }else if handymanType == "Mechanic"{
                    user["handymanType"] = "Mechanic"
                }/*else{
                    displayAlert(title: "Error", message: "Please choose a handyman type")
                }*/
            }else{
                displayAlert(title: "Error", message: "Please choose a type of user")
            }
            
            
            user.signUpInBackground { (success,error) in
                if let errorT = error{
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }else{
                    print("Sign up success")
                    self.displayAlert(title: "Success", message: "You have signed up successfully")
                }
            }
        }
        
    }
    
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    
    
}

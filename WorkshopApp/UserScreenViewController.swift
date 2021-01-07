//
//  UserScreenViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/26/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

var typeOfHandyman: String = ""
var problemLat: Double = -1
var problemLon: Double = -1
var problemOpis: String = ""
var problemDatum: String = ""


class UserScreenViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapOutlet: MKMapView!
    @IBOutlet weak var issueLabel: UITextField!
    @IBOutlet weak var handymanTypeLabel: UITextField!
    
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2
        mapOutlet.addGestureRecognizer(uilpgr)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapOutlet.delegate = self
        mapOutlet.mapType = .standard
        mapOutlet.isZoomEnabled = true
        mapOutlet.isScrollEnabled = true
        
        if let coor = mapOutlet.userLocation.location?.coordinate{
            mapOutlet.setCenter(coor, animated: true)
        }
        
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: self.mapOutlet)
            let newCoordinate = self.mapOutlet.convert(touchPoint, toCoordinateFrom: self.mapOutlet)
            
            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            problemLat = newCoordinate.latitude //lat za kreiranje lokacija na defektot
            problemLon = newCoordinate.longitude //lon za kreiranje lokacija na defektor
            
            var title = ""
            CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let placemark = placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    }
                    if title == "" {
                        title = "Added \(NSDate())"
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = newCoordinate
                    annotation.title = title
                    self.mapOutlet.addAnnotation(annotation)
                }
            })
        }
    }
    
    /*func showOnMap(){
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        mapOutlet.removeAnnotation(mapOutlet!.annotations as! MKAnnotation)
        let center = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapOutlet.setRegion(region, animated: true)
        
        let anno = MKPointAnnotation()
        anno.coordinate = userLocation
        anno.title = "Your location"
        mapOutlet.addAnnotation(anno)
        
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord:CLLocationCoordinate2D = manager.location?.coordinate{
            mapOutlet.mapType = MKMapType.standard
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coord, span: span)
            mapOutlet.setRegion(region, animated: true)
            
            let anno = MKPointAnnotation()
            anno.coordinate = coord
            anno.title = "Your location"
            mapOutlet.addAnnotation(anno)
        }
    }
    
    
    @IBAction func findButton(_ sender: Any) {
        if handymanTypeLabel.text != "" && issueLabel.text != ""{
            if handymanTypeLabel.text == "Electrician" || handymanTypeLabel.text == "Plumber" || handymanTypeLabel.text == "Mechanic"{
                //perform segue nakaj lista so majstori i prenesi tip na majstor
                typeOfHandyman = handymanTypeLabel.text! //tip na majstor
                problemOpis = issueLabel.text!
                performSegue(withIdentifier: "toHandymanList", sender: nil)
            }else{
                displayAlert(title: "Error", message: "Type is not available. Available types: Electrician, Plumber, Mechanic")
            }
        }else{
            displayAlert(title: "Error", message: "You must provide both explanation and type of handyman")
        }
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func jobsButton(_ sender: Any) {
        performSegue(withIdentifier: "toJobs", sender: nil)
    }
    
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    
}

//
//  ActiveJobDetailsViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/29/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

class ActiveJobDetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    let objId = activeJobId //objectId za rabotata
    var baranje1 = PFObject()
    var korisnik = PFUser()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var opisLabel: UILabel!
    @IBOutlet weak var imeLabel: UILabel!
    @IBOutlet weak var prezimeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var detailMap: MKMapView!
    @IBOutlet weak var cenaField: UITextField!
    @IBOutlet weak var datumField: UITextField!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Vleze")
        
        let query = PFQuery(className: "Baranje")
        query.whereKey("objectId", equalTo: objId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)! )
            }else{
                if let baranja = objects{
                    for baranje in baranja{
                        
                        self.baranje1 = baranje
                        
                        self.dateLabel.text = (baranje.object(forKey: "datum") as! String).components(separatedBy: " ").first
                        self.opisLabel.text = baranje.object(forKey: "opis") as! String
                        self.imeLabel.text = baranje.object(forKey: "imeKorisnik") as! String
                        self.prezimeLabel.text = baranje.object(forKey: "prezimeKorisnik") as! String
                        
                        
                        if let korisnikId: String = baranje.object(forKey: "userId") as! String{
                            let userQuery = PFUser.query()
                            do{
                                self.korisnik = try userQuery?.getObjectWithId(korisnikId) as! PFUser
                            }catch{
                                self.displayAlert(title: "Error", message: "User Query Unsuccessful")
                            }
                            self.emailLabel.text = self.korisnik.username
                            self.telLabel.text = self.korisnik.object(forKey: "phone") as! String
                            
                        }
                        
                        self.locationManager.requestWhenInUseAuthorization()
                        
                        if CLLocationManager.locationServicesEnabled(){
                            self.locationManager.delegate = self
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                            self.locationManager.startUpdatingLocation()
                        }
                        
                        self.detailMap.delegate = self
                        self.detailMap.mapType = .standard
                        self.detailMap.isZoomEnabled = true
                        self.detailMap.isScrollEnabled = true
                        
                        if let lat: Double = baranje.object(forKey: "lat") as! Double{
                            if let lon: Double = baranje.object(forKey: "lon") as! Double{
                                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                let region = MKCoordinateRegion(center: coordinate, span: span)
                                self.detailMap.setRegion(region, animated: true)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                annotation.title = "Problem Location"
                                self.detailMap.addAnnotation(annotation)
                            }
                        }
                    }
                }
            }
        }
    }
    
        

    @IBAction func AcceptButton(_ sender: Any) {
        baranje1["status"] = "Dobiena Ponuda"
        if datumField.text != "" && cenaField.text != ""{
            baranje1["datumPonuda"] = datumField.text
            baranje1["cena"] = cenaField.text
        }else{
            displayAlert(title: "Error", message: "You must enter both cena and datum")
        }
        
    }
    
    
    @IBAction func DenyButton(_ sender: Any) {
        baranje1["status"] = "Odbieno"
        let queryT = PFQuery(className: "Baranje")
        do{
            let bar = try queryT.getObjectWithId(objId)
            bar.deleteEventually()
        }catch{
            print("Error in delete query")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.detailMap.setRegion(region, animated: true)
    }
    
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    

}


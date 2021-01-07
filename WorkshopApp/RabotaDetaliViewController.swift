//
//  RabotaDetaliViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 1/6/21.
//  Copyright © 2021 David Petrushevski. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation


class RabotaDetaliViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var objId = activeJobUniqueId
    
    var korisnik = PFUser()
    
    let lat = detailLat
    let lon = detailLon
    
    
    @IBOutlet weak var jobDatumLabel: UILabel!
    @IBOutlet weak var jobOpisLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    @IBOutlet weak var userImePrez: UILabel!
    @IBOutlet weak var useTelNumLabel: UILabel!
    
    @IBOutlet weak var detailMap: MKMapView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    
   
    @IBOutlet weak var cenaField: UITextField!
    @IBOutlet weak var datumField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let reg = MKCoordinateRegion(center: coord, span: span)
        self.detailMap.setRegion(reg, animated: true)
        
        let anno = MKPointAnnotation()
        anno.coordinate = coord
        anno.title = "Problem Location"
        self.detailMap.addAnnotation(anno)
        
        
        let query = PFQuery(className: "Baranje")
        query.whereKey("objectId", equalTo: objId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                for baranje in objects!{
                    self.jobDatumLabel.text = (baranje.object(forKey: "datum") as! String).components(separatedBy: " ").first
                    self.jobOpisLabel.text = baranje.object(forKey: "opis") as! String
                    self.userImePrez.text = (baranje.object(forKey: "imeKorisnik") as! String) + " " + (baranje.object(forKey: "prezimeKorisnik") as! String)
                    
                    let userQuery = PFUser.query()
                    do{
                        var usrId = baranje.object(forKey: "userId") as! String
                        self.korisnik = try userQuery?.getObjectWithId(usrId) as! PFUser
                    }catch{
                        self.displayAlert(title: "Error", message: "User Query Error")
                    }
                    
                    self.userEmailLabel.text = self.korisnik.username
                    self.useTelNumLabel.text = self.korisnik.object(forKey: "phone") as! String
                }
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.detailMap.setRegion(region, animated: true)
    }
    

    @IBAction func sendPressed(_ sender: Any) {
        
        if datumField.text != "" && cenaField.text != ""{
            
            let query = PFQuery(className: "Baranje")
            query.whereKey("objectId", equalTo: objId)
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }else{
                    if let baranja = objects{
                        for obj in baranja{
                            obj["datumPonuda"] = self.datumField.text
                            obj["cena"] = self.cenaField.text
                            obj["status"] = "Dobiena Ponuda"
                            obj.saveInBackground()
                        }
                    }
                }
            }
            
        }else{
            displayAlert(title: "Error", message: "You must enter both cena and datum")
        }
    }
    
    
    @IBAction func denyPressed(_ sender: Any) {
        let query = PFQuery(className: "Baranje")
        query.whereKey("objectId", equalTo: objId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                if let baranja = objects{
                    for obj in baranja{
                        obj["status"] = "Odbieno"
                        obj.deleteInBackground()
                    }
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

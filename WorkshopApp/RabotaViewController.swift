//
//  RabotaViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 1/1/21.
//  Copyright © 2021 David Petrushevski. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit


extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

class RabotaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let jobId = rabotaId
    var korisnik = PFUser()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var imeLabel: UILabel!
    @IBOutlet weak var prezimeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telNumLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBOutlet weak var finishDateField: UITextField!
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        finishDateField.isHidden = true
        jobImage.isHidden = true
        chooseButton.isHidden = true
        saveButton.isHidden = true
        
        let query = PFQuery(className: "Baranje")
        query.whereKey("objectId", equalTo: jobId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                for baranje in objects!{
                    self.dateLabel.text = (baranje.object(forKey: "datum") as! String).components(separatedBy: " ").first
                    self.statusLabel.text = baranje.object(forKey: "status") as! String
                    self.imeLabel.text = baranje.object(forKey: "imeKorisnik") as! String
                    self.prezimeLabel.text = baranje.object(forKey: "prezimeKorisnik") as! String
                    
                    
                    if self.statusLabel.text == "Zakazana Rabota"{
                        self.finishDateField.isHidden = false
                        self.jobImage.isHidden = false
                        self.chooseButton.isHidden = false
                        self.saveButton.isHidden = false
                    }
                    
                    let userQuery = PFUser.query()
                    do{
                        var ajdi = baranje.object(forKey: "userId") as! String
                        self.korisnik = try userQuery?.getObjectWithId(ajdi) as! PFUser
                    }catch{
                        self.displayAlert(title: "Error", message: "User Query Error")
                    }
                    
                    self.emailLabel.text = self.korisnik.username
                    self.telNumLabel.text = self.korisnik.object(forKey: "phone") as! String
                    
                    
                    let newCoordinate = CLLocationCoordinate2D(latitude: (baranje.object(forKey: "lat") as! Double), longitude: (baranje.object(forKey: "lon") as! Double))
                    let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                    var title = ""
                    CLGeocoder().reverseGeocodeLocation(newLocation) { (placemarks, error) in
                        if error != nil{
                            print(error?.localizedDescription)
                        }else{
                            if let placemark = placemarks?[0]{
                                if placemark.subThoroughfare != nil{
                                    title += placemark.subThoroughfare! + " "
                                }
                                if placemark.thoroughfare != nil{
                                    title += placemark.thoroughfare!
                                }
                            }
                        }
                    }
                    
                    self.addressLabel.text = title
                }
            }
        }
        
    }
    

   
    @IBAction func navigateButton(_ sender: Any) {
        
    }
    
    @IBAction func imageButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            jobImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if let img = jobImage.image{
            if let imageData = img.jpeg(.medium) {
                let imageFile = PFFileObject(name: "image.jpg", data: imageData)
                
                
                let finishedJob = PFObject(className: "FinishedJob")
                finishedJob["majstorId"] = PFUser.current()?.objectId
                finishedJob["datum"] = self.finishDateField.text
                finishedJob["slika"] = imageFile
                finishedJob.saveInBackground { (success, error) in
                    if success{
                        print("finished job added")
                    }else{
                        print("error adding finished job")
                    }
                }
                
                
                
                
                let query = PFQuery(className: "Baranje")
                query.whereKey("objectId", equalTo: jobId)
                query.findObjectsInBackground { (objects, error) in
                    if error != nil{
                        self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                    }else{
                        for baranje in objects!{
                            baranje["slika"] = imageFile
                            baranje["datumZavrsuvanje"] = self.finishDateField.text
                            baranje["status"] = "Zavrsena Rabota"
                            baranje.saveInBackground()
                        }
                    }
                }
            }
        }
        self.displayAlert(title: "Success", message: "Saved")
    }
    
    
    func displayAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
}

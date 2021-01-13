//
//  DetailsViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/27/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse

class DetailsViewController: UIViewController {
    
    var majstor = PFUser()
    var majstorId1: String = ""
    //var job = PFObject()
    var ponudaTip: String = ""
    
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var imePrezLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var telLabel: UILabel!
    @IBOutlet weak var opisLabel: UILabel!
    
    @IBOutlet weak var statuslabel: UILabel!
    
    @IBOutlet weak var cenaPonudaLabel: UILabel!
    @IBOutlet weak var datumPonudaLabel: UILabel!
    
    
    @IBOutlet weak var firstButtonOutlet: UIButton!
    @IBOutlet weak var secondButtonOutlet: UIButton!
    
    @IBOutlet weak var jobImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cenaPonudaLabel.isHidden = true
        datumPonudaLabel.isHidden = true
        firstButtonOutlet.isHidden = true
        secondButtonOutlet.isHidden = true
        
        jobImage.isHidden = true
        
        
        let jobQuery = PFQuery(className: "Baranje")
        jobQuery.whereKey("objectId", equalTo: baranjeId)
        jobQuery.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                if let baranja = objects{
                    for baranje in baranja{
                        
                        //self.job = baranje
                        
                        self.datumLabel.text = baranje.object(forKey: "datum") as! String
                        self.statuslabel.text = baranje.object(forKey: "status") as! String
                        self.opisLabel.text = baranje.object(forKey: "opis") as! String
                        self.majstorId1 = baranje.object(forKey: "majstorId") as! String
                        
                        //let baranMajstor = PFUser(withoutDataWithObjectId: majstorId)
                        var majQuer = PFUser.query()
                        do{
                            self.majstor = try majQuer?.getObjectWithId(self.majstorId1) as! PFUser
                        }catch{
                            self.displayAlert(title: "Error", message: "User Query Error")
                        }
                        
                        self.tipLabel.text = self.majstor.object(forKey: "handymanType") as! String
                        self.imePrezLabel.text = (self.majstor.object(forKey: "firstName")) as! String + " " + (self.majstor.object(forKey: "lastName") as! String)
                        self.emailLabel.text = self.majstor.username
                        self.telLabel.text = self.majstor.object(forKey: "phone") as! String
                        
                        
                        if baranje.object(forKey: "status") as! String == "Aktivno"{
                            self.ponudaTip = "Aktivno"
                            self.firstButtonOutlet.isHidden = false
                            self.firstButtonOutlet.titleLabel?.text = "Otkazi"
                        }else if baranje.object(forKey: "status") as! String == "Dobiena Ponuda"{
                            self.ponudaTip = "Dobiena Ponuda"
                            self.firstButtonOutlet.isHidden = false
                            self.firstButtonOutlet.titleLabel?.text = "Prifati"
                            self.secondButtonOutlet.isHidden = false
                            self.secondButtonOutlet.titleLabel?.text = "Odbij"
                            
                            self.datumPonudaLabel.isHidden = false
                            self.datumPonudaLabel.text = baranje.object(forKey: "datumPonuda") as! String
                            
                            self.cenaPonudaLabel.isHidden = false
                            self.cenaPonudaLabel.text = baranje.object(forKey: "cena") as! String
                            
                        }else if baranje.object(forKey: "status") as! String == "Zakazana Rabota"{
                            self.ponudaTip = "Zakazana Rabota"
                            self.datumPonudaLabel.isHidden = false
                            self.datumPonudaLabel.text = baranje.object(forKey: "datumPonuda") as! String
                        }else if baranje.object(forKey: "status") as! String == "Zavrsena Rabota"{
                            //stavi slika od rabotata
                            self.ponudaTip = "Zavrsena Rabota"
                            self.jobImage.isHidden = false
                            let img = baranje.object(forKey: "slika") as! PFFileObject
                            img.getDataInBackground{ (data,error) in
                                if let imageData = data{
                                    if let imageToDisplay = UIImage(data: imageData){
                                        self.jobImage.image = imageToDisplay
                                    }
                                }
                            }
                            
                            self.datumPonudaLabel.isHidden = false
                            self.datumPonudaLabel.text = baranje.object(forKey: "datumZavrsuvanje") as! String
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    
    @IBAction func firstPressed(_ sender: Any) {
        if self.ponudaTip == "Aktivno"{
            let query = PFQuery(className: "Baranje")
            query.whereKey("objectId", equalTo: baranjeId)
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }else{
                    if let baranja = objects{
                        for obj in baranja{
                            obj.deleteInBackground()
                        }
                    }
                }
            }
            firstButtonOutlet.isHidden = true
            self.displayAlert(title: "Success", message: "Offer deleted")
        }else if self.ponudaTip == "Dobiena Ponuda"{
            //prifati ponuda
            let query = PFQuery(className: "Baranje")
            query.whereKey("objectId", equalTo: baranjeId)
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }else{
                    if let baranja = objects{
                        for obj in baranja{
                            obj["status"] = "Zakazana Rabota"
                            obj.saveInBackground(block: { (success, error) in
                                if success{
                                    self.displayAlert(title: "Success", message: "Prifatena ponuda")
                                }else{
                                    self.displayAlert(title: "Error", message: "Problem")
                                }
                            })
                        }
                    }
                }
            }
            self.displayAlert(title: "Success", message: "Offer accepted")
            firstButtonOutlet.isHidden = true
        }
    }
    
    
    @IBAction func secondButtonAction(_ sender: Any) {
        if self.ponudaTip == "Dobiena Ponuda"{
            //odbij ponuda
            let query = PFQuery(className: "Baranje")
            query.whereKey("objectId", equalTo: baranjeId)
            query.findObjectsInBackground { (objects, error) in
                if error != nil{
                    self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                }else{
                    if let baranja = objects{
                        for obj in baranja{
                            obj["status"] = "Aktivno"
                            obj.saveInBackground()
                        }
                    }
                }
            }
            self.displayAlert(title: "Success", message: "Offer denied")
            firstButtonOutlet.isHidden = true
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

//
//  PortfolioTableViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/26/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse

class PortfolioTableViewController: UITableViewController {
    
    let majstorObjId = majstorId //id na majstorot
    let imeM = majstorIme
    let prezM = majstorPrezime
    
    var sliki = [PFFileObject]()
    var datumi = [String]()
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className: "FinishedJob")
        query.whereKey("majstorId", equalTo: majstorObjId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                for obj in objects!{
                    print("vleze vo objekti")
                    self.datumi.append(obj["datum"] as! String)
                    print("stavi datum")
                    self.sliki.append(obj.object(forKey: "slika") as! PFFileObject)
                    print("stavi slika")
                    
                    self.tableView.reloadData()
                }
            }
            print("Napokon")
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datumi.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "portfolioCell", for: indexPath) as! PortfolioTableViewCell
        
        cell.dateLabel.text = datumi[indexPath.row]
        print("datumot se stavi vo kelijata")
        
        sliki[indexPath.row].getDataInBackground { (data, error) in
            if let imageData = data{
                if let imageToDisplay = UIImage(data: imageData){
                    cell.jobImage.isHidden = false
                    cell.jobImage.image = imageToDisplay
                }
            }
        }
        print("slikata se stavi vo kelijata")
        
        
        return cell
    }
    
    @IBAction func choosePressed(_ sender: Any) {
        let currUser = PFUser.current()
        let baranje = PFObject(className: "Baranje")
        baranje["majstorId"] = majstorObjId
        baranje["imeMajstor"] = imeM
        baranje["prezimeMajstor"] = prezM
        baranje["status"] = "Aktivno"
        baranje["userId"] =  currUser?.objectId
        baranje["imeKorisnik"] = currUser?.object(forKey: "firstName") as! String
        baranje["prezimeKorisnik"] = currUser?.object(forKey: "lastName") as! String
        baranje["opis"] = problemOpis
        baranje["lat"] = problemLat
        baranje["lon"] = problemLon
        baranje["datumZavrsuvanje"] = "None"
        let currDate = Date()
        baranje["datum"] = currDate.description
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        UIApplication.shared.beginIgnoringInteractionEvents()
        baranje.saveInBackground { (success, error) in
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            if success{
                self.displayAlert(title: "Success", message: "Successful request")
            }else{
                self.displayAlert(title: "Error", message: "Unsuccesful request")
            }
        }
    }
    
    
    
    
    /*
    @objc func updateTable(){
        
        self.datumi.removeAll()
        self.sliki.removeAll()
        
        let query = PFQuery(className: "FinishedJob")
        query.whereKey("majstorId", equalTo: majstorObjId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                for obj in objects!{
                    print("vleze vo objekti")
                    self.datumi.append(obj.object(forKey: "datum") as! String)
                    print("stavi datum")
                    self.sliki.append(obj["slika"] as! PFFileObject)
                    print("stavi slika")
                    
                    self.tableView.reloadData()
                }
            }
            print("Napokon")
        }
    }*/
    
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }*/
    
    
}

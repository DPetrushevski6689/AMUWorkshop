//
//  HandymenListTableViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/26/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

var majstorId: String = ""
var majstorIme: String = ""
var majstorPrezime: String = ""

class HandymenListTableViewController: UITableViewController {

    var firstNames = [String]()
    var lastNames = [String]()
    var objectIds = [String]()
    
    var majstorLons = [Double]()
    var majstorLats = [Double]()
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    
    
    let problemLocation = CLLocation(latitude: problemLat, longitude: problemLon) //lokacija na defektot -> longpress
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(HandymenListTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return firstNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HandymanCell", for: indexPath) as! HandymenTableViewCell

        let majstorId = objectIds[indexPath.row]
        
        let baranjaQuery = PFQuery(className: "Baranje")
        baranjaQuery.whereKey("majstorId", equalTo: majstorId)
        baranjaQuery.whereKey("status", equalTo: "Aktivno")
        baranjaQuery.findObjectsInBackground { (objects, error) in
            if let baranja = objects{
                if baranja.count > 0{
                    cell.checkedLabel.text = "*"
                }else{
                    cell.checkedLabel.text = ""
                }
            }
        }
        
        if let posLon: Double = majstorLons[indexPath.row]{
            if let posLat: Double = majstorLats[indexPath.row]{
                let majstorLocation = CLLocation(latitude: posLon, longitude: posLat)
                let distance = (problemLocation.distance(from: majstorLocation)) / 1000
                cell.distanceLabel.text = distance as? String
            }
        }
        
        cell.nameLabel.text = firstNames[indexPath.row]
        cell.surnameLabel.text = lastNames[indexPath.row]
        
        
        return cell
    }
    
    @objc func updateTable(){
        self.firstNames.removeAll()
        self.lastNames.removeAll()
        self.objectIds.removeAll()
        self.majstorLats.removeAll()
        self.majstorLons.removeAll()
        
        let query = PFUser.query()
        query?.whereKey("handymanType", equalTo: typeOfHandyman)
        
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else if let users = users{
                for object in users{
                    if let user = object as? PFUser{
                        if let objId = user.objectId{
                            if let firstName = user.object(forKey: "firstName"){
                                if let lastName = user.object(forKey: "lastName"){
                                    self.firstNames.append(firstName as! String)
                                    self.lastNames.append(lastName as! String)
                                    self.objectIds.append(objId)
                                    self.majstorLons.append(user.object(forKey: "lon") as! Double)
                                    self.majstorLats.append(user.object(forKey: "lat") as! Double)
                                    if self.firstNames.count == users.count
                                    {
                                        self.refresher.endRefreshing()
                                        self.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        majstorId = objectIds[indexPath.row] //object id za izbraniot majstor
        majstorIme = firstNames[indexPath.row]
        majstorPrezime = lastNames[indexPath.row]
        
        performSegue(withIdentifier: "toPortfolio", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    
}

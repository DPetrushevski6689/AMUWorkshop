//
//  HandymanTableViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/29/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse

var activeJobUniqueId: String = ""
var detailLat: Double = -1
var detailLon: Double = -1

class HandymanTableViewController: UITableViewController {

    var dates = [String]()
    var userNames = [String]()
    var userSurnames = [String]()
    
    var lats = [Double]()
    var lons = [Double]()
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    var jobIds = [String]()
    
    let userId = PFUser.current()?.objectId //majstorId
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(HandymanTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "handyCell", for: indexPath) as! HandymanTableViewCell

        cell.dateLabel.text = dates[indexPath.row].components(separatedBy: " ").first
        cell.nameLabel.text = userNames[indexPath.row]
        cell.surnameLabel.text = userSurnames[indexPath.row]

        return cell
    }
    
    @objc func updateTable(){
        self.dates.removeAll()
        self.userNames.removeAll()
        self.userSurnames.removeAll()
        
        let query = PFQuery(className: "Baranje")
        query.whereKey("status", equalTo: "Aktivno")
        query.whereKey("majstorId", equalTo: userId)
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                if let baranja = objects{
                    for baranje in baranja{
                        self.dates.append(baranje.object(forKey: "datum") as! String)
                        self.userNames.append(baranje.object(forKey: "imeKorisnik") as! String)
                        self.userSurnames.append(baranje.object(forKey: "prezimeKorisnik") as! String)
                        self.jobIds.append(baranje.objectId!)
                        
                        self.lats.append(baranje.object(forKey: "lat") as! Double)
                        self.lons.append(baranje.object(forKey: "lon") as! Double)
                        
                        self.tableView.reloadData()
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
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        PFUser.logOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeJobUniqueId = jobIds[indexPath.row]
        detailLat = lats[indexPath.row]
        detailLon = lons[indexPath.row]
        performSegue(withIdentifier: "toRabotaDetali", sender: nil)
    }
    
    
    
    @IBAction func rabotiPressed(_ sender: Any) {
        performSegue(withIdentifier: "toRaboti", sender: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

}

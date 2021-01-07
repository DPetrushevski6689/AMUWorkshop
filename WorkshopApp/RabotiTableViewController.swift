//
//  RabotiTableViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 1/1/21.
//  Copyright © 2021 David Petrushevski. All rights reserved.
//

import UIKit
import Parse

var rabotaId: String = ""

class RabotiTableViewController: UITableViewController {
    
    var refresher:UIRefreshControl = UIRefreshControl()
    
    var dates = [String]()
    var userNames = [String]()
    var userSurnames = [String]()
    var jobIds = [String]()
    var statuses = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(RabotiTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RabotiCelll", for: indexPath) as! RabotiTableViewCell

        if statuses[indexPath.row] == "Zakazana Rabota"{
            cell.backgroundColor = UIColor.red
            cell.dateLabel.text = dates[indexPath.row]
            cell.imeLabel.text = userNames[indexPath.row]
            cell.prezimeLabel.text = userSurnames[indexPath.row]
        }else if statuses[indexPath.row] == "Zavrsena Rabota"{
            cell.backgroundColor = UIColor.green
            cell.dateLabel.text = dates[indexPath.row]
            cell.imeLabel.text = userNames[indexPath.row]
            cell.prezimeLabel.text = userSurnames[indexPath.row]
        }else{
            cell.dateLabel.text = ""
            cell.imeLabel.text = ""
            cell.prezimeLabel.text = ""
        }

        return cell
    }
    
    @objc func updateTable(){
        
        print("Vlegov vo update")
        
        self.dates.removeAll()
        self.userNames.removeAll()
        self.userSurnames.removeAll()
        
        let query = PFQuery(className: "Baranje")
        query.whereKey("majstorId", equalTo: (PFUser.current()?.objectId))
        //query.whereKey("status", containedIn: ["Zavrsena Rabota", "Zakazana Rabota"])
        //query.whereKey("status", equalTo: "Zakazana Rabota")
        //query.whereKey("status", equalTo: "Zavrsena Rabota")
        print("mi naprai query")
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                for baranje in objects!{
                    print("ima objekti")
                        self.dates.append((baranje.object(forKey: "datum") as! String).components(separatedBy: " ").first!)
                        self.userNames.append(baranje.object(forKey: "imeKorisnik") as! String)
                        self.userSurnames.append(baranje.object(forKey: "prezimeKorisnik") as! String)
                        self.jobIds.append(baranje.objectId!)
                        self.statuses.append(baranje.object(forKey: "status") as! String)
                        
                    if self.dates.count == objects!.count{
                            self.refresher.endRefreshing()
                            self.tableView.reloadData()
                        }
                    }
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rabotaId = jobIds[indexPath.row]
        
        performSegue(withIdentifier: "toRabotaDetails", sender: nil)
    }
    
    func displayAlert(title: String, message:String){
        let alertCont = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCont.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertCont, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

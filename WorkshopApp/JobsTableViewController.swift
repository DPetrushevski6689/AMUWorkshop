//
//  JobsTableViewController.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/27/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit
import Parse

var baranjeId: String = ""

class JobsTableViewController: UITableViewController {
    
    var datumi = [String]()
    var names = [String]()
    var surnames = [String]()
    var statusi = [String]()
    var baranjaIds = [String]()
    
    var refresher:UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(JobsTableViewController.updateTable), for: UIControl.Event.valueChanged)
        self.view.addSubview(refresher)
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return names.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobsCell", for: indexPath) as! JobsTableViewCell

        cell.datumLabel.text = datumi[indexPath.row].components(separatedBy: " ").first
        cell.imeLabel.text = names[indexPath.row]
        cell.prezimeLabel.text = surnames[indexPath.row]
        
        if statusi[indexPath.row] == "Aktivno"{
            cell.backgroundColor = UIColor.yellow
        }else if statusi[indexPath.row] == "Dobiena Ponuda"{
            cell.backgroundColor = UIColor.red
        }else if statusi[indexPath.row] == "Zakazana Rabota"{
            cell.backgroundColor = UIColor.blue
        }else if statusi[indexPath.row] == "Zavrsena Rabota"{
            cell.backgroundColor = UIColor.green
        }
        
        return cell
    }
    
    @objc func updateTable()
    {
        self.names.removeAll()
        self.surnames.removeAll()
        self.datumi.removeAll()
        self.statusi.removeAll()
        self.baranjaIds.removeAll()
        
        let query = PFQuery(className: "Baranje")
        query.findObjectsInBackground { (objects, error) in
            if error != nil{
                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
            }else{
                if let baranja = objects{
                    for baranje in baranja{
                        self.datumi.append(baranje.object(forKey: "datum") as! String)
                        self.names.append(baranje.object(forKey: "imeMajstor") as! String)
                        self.surnames.append(baranje.object(forKey: "prezimeMajstor") as! String)
                        self.statusi.append(baranje.object(forKey: "status") as! String)
                        self.baranjaIds.append(baranje.objectId!)
                        if self.names.count == baranja.count{
                            self.refresher.endRefreshing()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baranjeId = baranjaIds[indexPath.row]
        performSegue(withIdentifier: "toDetails", sender: nil)
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

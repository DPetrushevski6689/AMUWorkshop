//
//  LoginViewController.swift
//  
//
//  Created by David Petrushevski on 12/22/20.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != ""{
            //login
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
                if let errorT = error{
                    let errorMsg = error?.localizedDescription
                    self.displayAlert(title: "Login Error", message: errorMsg!)
                }
                else{ //success login
                    print("Succesfull login")
                    if user?.object(forKey: "displayName") as! String == "User"{
                        self.performSegue(withIdentifier: "toUser", sender: nil)
                    }else if user?.object(forKey: "displayName") as! String == "Handyman"{
                        self.performSegue(withIdentifier: "toHandyman", sender: nil)
                    }
                }
            }
            
        }else{
            displayAlert(title: "Error", message: "Please enter your email and password to log in!")
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

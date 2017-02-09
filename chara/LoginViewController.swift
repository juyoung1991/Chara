//
//  ViewController.swift
//  chara
//
//  Created by Ju Young Kim on 2/1/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var user_email: UITextField!
    @IBOutlet weak var user_pwd: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func log_in(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.user_email.text!, password: self.user_pwd.text!, completion: { (auth, error) in
            if(error != nil){
                self.alertMessage(title: "Oops!", message: "Wrong email and password!")
            }else{
                self.performSegue(withIdentifier: "login", sender: nil)
            }
        })
    }
    
    /*
     Create an alert message box
     */
    func alertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


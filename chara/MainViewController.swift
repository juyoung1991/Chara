//
//  MainViewController.swift
//  chara
//
//  Created by Ju Young Kim on 2/5/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UITableViewController {
    
    let curr_uid = FIRAuth.auth()?.currentUser?.uid
    let curr_user = User()
    let queues = Queue()
    var loading = LoadingAnimation()
    let curr_queues : [Queue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curr_user.get_user_info(user_id: curr_uid!, myView: self.view)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Get all qeueus associated to curr user
     */
    
    func get_user_queue() {
        self.queues.get_all_queues(uiview: self.view)
    }
    
    
    /*
     Segue to addviewcontroller with the inst_list array
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addQueue"){
            let nextVC = segue.destination as! AddQueueViewController
            nextVC.curr_user = self.curr_user
        }
    }
    
    /*
     Get all queues associated with the current user
     */
    
    
    /*
     Logout function and segue back to log in view
     */
    @IBAction func logout(_ sender: Any) {
        do{
            try! FIRAuth.auth()!.signOut()
            self.performSegue(withIdentifier: "logout", sender: nil)
        } catch {
            print("error")
        }
    }
}


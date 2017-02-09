//
//  AddQueueViewController.swift
//  chara
//
//  Created by Ju Young Kim on 2/6/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import UIKit
import Firebase

class AddQueueViewController: UIViewController {
    
    var curr_queue_list : [Queue] = []
    
    var selected_class : String = ""
    
    var curr_user = User()
    
    let rootref = FIRDatabase.database().reference()
    
    @IBOutlet weak var add_queue: UIButton!
    
    @IBOutlet weak var modal_view: UIView!
    
    @IBOutlet weak var drop_btn: DropMenuButton!
    
    @IBOutlet weak var error_msg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        modal_view.layer.borderWidth = 1
        modal_view.layer.cornerRadius = 5
        
        drop_btn.layer.borderWidth = 1
        drop_btn.layer.cornerRadius = 5
        
        add_queue.layer.cornerRadius = 5
        
        error_msg.textColor = UIColor.red
        error_msg.isHidden = true
        
        drop_btn.initMenu(curr_user.user_inst_list, actions: get_action_list(inst_list: curr_user.user_inst_list))
        
        
    }
    /*
     Add a queue to database
     */
    @IBAction func add_queue(_ sender: Any) {
        if queue_exist_check(class_name: selected_class) {
            //add an error pop msg
            self.error_msg.isHidden = false
        }else {
            //Add a queue to firebase!
            let temp_ref = self.rootref.child("queues").childByAutoId()
            temp_ref.setValue(["course name": self.selected_class, "Instructor": self.curr_user.user_fn + " " + self.curr_user.user_ln])
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    /*
     Check is newly added queue already exists.
    */
    func queue_exist_check(class_name: String) -> Bool{
        for queue in curr_queue_list {
            if queue.course_name == class_name {
                return true
            }
        }
        return false
    }
    /*
     Create list of functions for each selected menu item and add actions to each of them
     */
    func get_action_list(inst_list: [String]) -> [() -> (Void)]{
        var fn_array = Array<() -> (Void)>()
        
        for i in 0...inst_list.count {
           fn_array.append({ () -> (Void) in
                self.selected_class = inst_list[i]
           })
        }
        return fn_array
    }
    
    /*
     Dismiss modal when clicked outside the modal view
     */
    @IBAction func dismiss_modal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

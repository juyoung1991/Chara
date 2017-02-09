//
//  Queue.swift
//  chara
//
//  Created by Ju Young Kim on 2/5/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import Foundation
import Firebase

class Queue {
    var course_name : String = ""
    var inst_name : String = ""
    var students : [NSDictionary] = []
    var loading = LoadingAnimation()
    var all_queue : [Queue] = []

    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    
    /*
     Get queue with the corresponding unique id
     */
    func get_queue(qid: String, uiview: UIView) {
        loading.showActivityIndicator(uiView: uiview)
        ref.child("queues").child(qid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.loading.showActivityIndicator(uiView: uiview)
            let queue_info = snapshot.value as! NSDictionary
            self.inst_name = queue_info.value(forKey: "Instructor") as! String
            self.course_name = queue_info.value(forKey: "course name") as! String
            if queue_info.value(forKey: "students") == nil {
                self.students = []
            }else{
                for(student_id, student_info) in queue_info.value(forKey: "students") as! NSDictionary {
                    let student_info_dict = student_info as! NSDictionary
                    self.students.append(["student_id": student_id, "added_time": student_info_dict.value(forKey: "added_time"), "location": student_info_dict.value(forKey: "location"), "title": student_info_dict.value(forKey: "title"), "name": student_info_dict.value(forKey: "name")])
                }
            }
            self.loading.hideActivityIndicator(uiView: uiview)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /*
     Get all queues
     */
    func get_all_queues(uiview: UIView) {
        loading.showActivityIndicator(uiView: uiview)
        ref.child("queues").observeSingleEvent(of: .value, with: { (snapshot) in
            let queues = snapshot.value as! NSDictionary
            for (queue_id, queue_info) in queues {
                let queue_el = Queue()
                queue_el.inst_name = (queue_info as! NSDictionary).value(forKey: "Instructor") as! String
                queue_el.course_name = (queue_info as! NSDictionary).value(forKey: "course name") as! String
                if (queue_info as! NSDictionary).value(forKey: "students") == nil {
                    queue_el.students = []
                }else{
                    for (student_id, student_info) in (queue_info as! NSDictionary).value(forKey: "students") as! NSDictionary {
                        let student_info_dict = student_info as! NSDictionary
                        queue_el.students.append(["student_id": student_id, "added_time": student_info_dict.value(forKey: "added_time"), "location": student_info_dict.value(forKey: "location"), "title": student_info_dict.value(forKey: "title"), "name": student_info_dict.value(forKey: "name")])
                    }
                }
                self.all_queue.append(queue_el)
            }
            print("PRINTING LIST OF ALL THE QUEUES....")
            for queue in self.all_queue {
                print(queue.course_name)
                print(queue.inst_name)
                print(queue.students)
            }
            self.loading.hideActivityIndicator(uiView: uiview)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

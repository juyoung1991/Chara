//
//  User.swift
//  chara
//
//  Created by Ju Young Kim on 2/5/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class User {
    var user_email : String = ""
    var user_fn : String = ""
    var user_ln : String = ""
    var user_pic : UIImage? = nil
    var user_inst_list : [String] = []
    var user_student_list : [String] = []
    var loading = LoadingAnimation()
    
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()

    /*
     Get curr user info
     */
    func get_user_info(user_id: String, myView: UIView) {
        self.loading.showActivityIndicator(uiView: myView)
        ref.child("users").child(user_id).observeSingleEvent(of: .value, with: { (snapshot) in
            let user_info = snapshot.value as! NSDictionary
            self.user_email = user_info.value(forKey: "email") as! String
            self.user_fn = user_info.value(forKey: "first name") as! String
            self.user_ln = user_info.value(forKey: "last name") as! String
            self.user_inst_list = user_info.value(forKey: "Instructing") as! [String]
            self.user_student_list = user_info.value(forKey: "Taking") as! [String]
            
            let user_pic_url = user_info.value(forKey: "profile_pic") as! String
            
            let image_ref = FIRStorage.storage().reference(forURL: user_pic_url)
            image_ref.data(withMaxSize: 10*1024*1024, completion: { (data, error) in
                if(error != nil){
                    print("error getting image!")
                }else{
                    let user_image = UIImage(data: data!)
                    self.user_pic = user_image!
                    self.loading.hideActivityIndicator(uiView: myView)
                    //If it reaches here. Then all user info is retrieved
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}

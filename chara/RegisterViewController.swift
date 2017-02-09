//
//  RegisterViewController.swift
//  chara
//
//  Created by Ju Young Kim on 2/4/17.
//  Copyright © 2017 Ju Young Kim. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash
import Alamofire
import Firebase
import FirebaseStorage

/*
 Compresses image size
 Source: http://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
 */
extension UIImage {
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var user_email: UITextField!
    @IBOutlet weak var user_fn: UITextField!
    @IBOutlet weak var user_ln: UITextField!
    @IBOutlet weak var user_pwd: UITextField!
    @IBOutlet weak var user_profile: UIImageView!
    var sem_type : String = ""
    @IBOutlet weak var fall_btn: UIButton!
    @IBOutlet weak var spring_btn: UIButton!
    @IBOutlet weak var scroll_view: UIScrollView!
    @IBOutlet weak var class_text: UITextField!
    @IBOutlet weak var add_class_btn: UIButton!
    @IBOutlet weak var register_btn: UIButton!
    var class_field_x : CGFloat = 0.0
    var class_field_y : CGFloat = 0.0
    var class_del_btn_x : CGFloat = 0.0
    var class_del_btn_y : CGFloat = 0.0
    var classes: [UITextField] = []
    var del_btns: [UIButton] = []
    var curr_pickerView : UIPickerView!
    
    var user_type: [String] = ["Instructor", "Student"]
    var major_list: [(String,String)] = []
    var course_list: [String] = []
    
    var inst_list : [String] = []
    var student_list : [String] = []
    
    var activeTextField = UITextField()
    
    let rootref = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show the navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        //Add gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss_keyboard(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
        //Add default user profile picture in case nothing is given
        user_profile.image = UIImage(named: "default.png")
        
        //Images set for radio buttons
        fall_btn.setBackgroundImage(UIImage(named: "uncheck-box.png"), for: .normal)
        spring_btn.setBackgroundImage(UIImage(named: "uncheck-box.png"), for: .normal)
        
        //Set global variables to get the (x,y) of the class text field
        class_field_x = self.class_text.frame.origin.x
        class_field_y = self.class_text.frame.origin.y
        class_del_btn_x = self.add_class_btn.frame.origin.x
        class_del_btn_y = self.add_class_btn.frame.origin.y
        classes.append(class_text)
        del_btns.append(add_class_btn)
        
        //Add scroll view and set its height
        scroll_view.isScrollEnabled = true
        scroll_view.contentSize.height = self.view.frame.height
        
        //Create an edit event listener to create pickerview for given textfield
        class_text.addTarget(self, action: #selector(create_pickerview_default), for: UIControlEvents.editingDidBegin)
        
        //Disable adding classes because nothing is input yet
        add_class_btn.isEnabled = false
    }
    
    

    
    
    
    /**
     ============================================== PICKERVIEW ===========================================================
     **/

    /*
     Create Pickerview for the first add class textfield
     */
    func create_pickerview_default(_ sender: UITextField){
        textFieldDidBeginEditing(textField: sender)
        let myPickerView = UIPickerView()
        myPickerView.delegate = self
        
        curr_pickerView = myPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss_pickerview))
        
        toolBar.setItems([doneButton], animated: false)
        
        sender.inputView = myPickerView
        sender.inputAccessoryView = toolBar
    }
    
    /*
     Create Pickerview for the rest of the added class textfield (if any)
     */
    func create_pickerview(_ sender: UITextField) {
        textFieldDidBeginEditing(textField: sender)
        self.major_list.removeAll()
        get_major_list()
        let myPickerView = UIPickerView()
        myPickerView.delegate = self
        
        curr_pickerView = myPickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss_pickerview))
        
        toolBar.setItems([doneButton], animated: false)
        
        sender.inputView = myPickerView
        sender.inputAccessoryView = toolBar
    }
    
    /*
     Function to end/dismiss the pickerview
     */
    func dismiss_pickerview(){
        self.view.endEditing(true)
    }
    
    /*
     Number of columns in current pickerview
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /*
     Number of items in each columns of current pickerview
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print(self.major_list.count)
        if(component == 0){
            return self.user_type.count
        }else if component == 1{
            return self.major_list.count
        }else{
            return self.course_list.count
        }
    }
    
    /*
     Set the value of each row of the current pickerview
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(component == 0){
            return self.user_type[row]
        }else if component == 1{
            return self.major_list[row].0
        }else {
            return self.course_list[row]
        }
    }
    
    /*
     Handler when a row is selected of the current pickerview
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let curr_major = self.major_list[pickerView.selectedRow(inComponent: 1)]
        get_course_list(course_name: curr_major.1)
        
    }
    
    /**
     ============================================== SEMESTER ===========================================================
     **/
    
    /*
     IBAction function when Fall semester is checked
     */
    @IBAction func fall_sem_clicked(_ sender: Any) {
        fall_btn.setBackgroundImage(UIImage(named: "check-box.png"), for: .normal)
        spring_btn.setBackgroundImage(UIImage(named: "uncheck-box.png"), for: .normal)
        sem_type = "fall"
        add_class_btn.isEnabled = true
        self.major_list.removeAll()
        get_major_list()
    }
    
    /*
     IBAction function when Spring semester is checked
     */
    @IBAction func spring_sem_clicked(_ sender: Any) {
        spring_btn.setBackgroundImage(UIImage(named: "check-box.png"), for: .normal)
        fall_btn.setBackgroundImage(UIImage(named: "uncheck-box.png"), for: .normal)
        sem_type = "spring"
        add_class_btn.isEnabled = true
        self.major_list.removeAll()
        get_major_list()
    }

    
    /**
     ============================================== HTTP REQUEST ===========================================================
     **/
    
    /*
     source: http://mrgott.com/swift-programing/30-work-with-rest-api-in-swift-3-and-xcode-8-using-urlsession-and-jsonserialization
     Http request to get all the course list in the given semester
     */
    func get_major_list() {
        
        let curr_year = get_curr_year()
        Alamofire.request("http://courses.illinois.edu/cisapp/explorer/schedule/" + String(curr_year) + "/" + sem_type + ".xml")
            .responseData { response in
                if let data = response.data {
                    let xml_string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
//                    print(xml_string)
                    
                    let xml = try! SWXMLHash.parse(xml_string)
                    for subject in xml["ns2:term"]["subjects"]["subject"] {
                        self.major_list.append(((subject.element?.text)!, (subject.element?.attribute(by: "id")?.text)!))
                    }
                    if self.curr_pickerView != nil {
                        self.curr_pickerView.reloadComponent(1)
                    }
                    self.get_course_list(course_name: self.major_list[0].1)
                    
                }
        }
    }
    
    func get_course_list(course_name:String) {
        self.course_list.removeAll()
        let curr_year = get_curr_year()
        Alamofire.request("http://courses.illinois.edu/cisapp/explorer/schedule/" + String(curr_year) + "/" + sem_type + "/" + course_name + ".xml")
            .responseData { response in
                if let data = response.data {
                    let xml_string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
//                    print(xml_string)
                    
                    let xml = try! SWXMLHash.parse(xml_string)
                    for course in xml["ns2:subject"]["courses"]["course"] {
//                        print(course.element?.attribute(by: "id")?.text)
                        self.course_list.append(course_name +  (course.element?.attribute(by: "id")?.text)!)
                    }
                    if self.curr_pickerView != nil {
                        self.curr_pickerView.reloadComponent(2)
                        self.activeTextField.text = self.user_type[self.curr_pickerView.selectedRow(inComponent: 0)] + " " + self.course_list[self.curr_pickerView.selectedRow(inComponent: 2)]
                    }
                }
        }
    }
    
    
    /**
     ============================================== PROFILE PICTURE ===========================================================
     **/
    
    
    /*
     Add profile picture from camera
     */
    @IBAction func add_prof_camera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    /*
     Add profile picture from photo album
     */
    @IBAction func add_prof_album(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /*
     Set the image view with the chosen image from album or camera
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            user_profile.image = image
        } else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    /**
     ============================================== ADD/DELETE NEW CLASS TEXTFIELD ===========================================================
     **/
    
    @IBAction func add_class(_ sender: Any) {
        
        //Add text field
        let class_text_size = CGSize(width: class_text.frame.width, height: class_text.frame.height)
        let textField = UITextField(frame: CGRect(origin: CGPoint(x: class_field_x, y: class_field_y + 40), size: class_text_size))
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.font = textField.font?.withSize(14.0)
        classes.append(textField)
        
        //Add delete button
        let del_btn = UIButton(frame: CGRect(origin: CGPoint(x: class_del_btn_x, y: class_del_btn_y + 40), size: add_class_btn.frame.size))
        del_btn.setBackgroundImage(UIImage(named: "remove.png"), for: .normal)
        del_btn.addTarget(self, action: #selector(delete_class(button:)), for: .touchUpInside)
        del_btns.append(del_btn)
        self.scroll_view.addSubview(textField)
        self.scroll_view.addSubview(del_btn)
        
        shift_offset(add: true, offset: 40)
        
        textField.addTarget(self, action: #selector(create_pickerview(_:)), for: UIControlEvents.editingDidBegin)
        
    }
    
    /*
     Shift corresponding offset according to its value
     */
    func shift_offset(add: Bool, offset: CGFloat){
        if add {
            class_field_y += offset
            class_del_btn_y += offset
            register_btn.frame.origin.y += offset
            scroll_view.contentSize.height += offset
        }else{
            class_field_y -= offset
            class_del_btn_y -= offset
            register_btn.frame.origin.y -= offset
            scroll_view.contentSize.height -= offset
        }
    }
    
    /*
     Helper function that removes a given UIView
     */
    func remove_subview(view: UIView){
        let subviews = self.scroll_view.subviews
        for subview in subviews {
            if subview == view{
                subview.removeFromSuperview()
            }
        }
    }
    
    /*
     Delete a class which will delete that particular textfield and uibutton
     */
    func delete_class(button: UIButton){
        
        //Get button index
        let index = del_btns.index(of: button)
        
        //Delete the corresponding textfield
        remove_subview(view: classes[index!])
        classes.remove(at: index!)
        
        //Delete the corresponding delete button
        remove_subview(view: button)
        del_btns.remove(at: index!)
        
        //Shift all textfield/buttons below it upwards by 40
        if del_btns.indices.contains(index!) {
            for i in index!...del_btns.count-1 {
                del_btns[i].frame.origin.y -= 40
                classes[i].frame.origin.y -= 40
            }
            shift_offset(add: false, offset: 40)
        }else {
            shift_offset(add: false, offset: 40)
        }
    }
    
    /**
     ============================================== FIREBASE/CREATE ACC ===========================================================
     **/
    
    //Thing to add : USERID [   email, first name, last name, profile pic, semester type, semester year, [Instruct class], [Student class]   ]
    
    @IBAction func create_account(_ sender: Any) {
        let email = user_email.text
        let first_name = user_fn.text
        let last_name = user_ln.text
        let user_pic = user_profile.image //firebase storage
        let sem_year = self.get_curr_year()
        let pwd = user_pwd.text
        
        
        
        if email != "" && first_name != "" && last_name != "" && sem_year != nil && pwd != "" && classes.count != 0{
            
            for course in classes {
                let course_arr = course.text!.components(separatedBy: " ")
                
                if course_arr[0] == "Instructor" {
                    self.inst_list.append(course_arr[1])
                }else{
                    self.student_list.append(course_arr[1])
                }
            }
            
            if (self.inst_list.count != 0 || self.student_list.count != 0){
                FIRAuth.auth()?.createUser(withEmail: email!, password: pwd!, completion:  { (user, error) in
                    if (error != nil){
                        self.alertMessage(title: "Oops!", message: (error?.localizedDescription)!)
                    }else{
                        let imageref = self.storageRef.child((user?.uid)!).child((first_name! + " " + last_name!))
                        let imageData = UIImagePNGRepresentation(user_pic!.resizeWith(percentage: 0.1)!)
                        let uploadTask = imageref.put(imageData!, metadata: nil, completion: { (metadata, error) in
                            if(error != nil){
                                self.alertMessage(title: "Oops!", message: "Error uploading to Firebase Storage.")
                            }else{
                                let img_url = metadata!.downloadURL()!
                                self.rootref.child("users").child((user!.uid)).setValue(["email": email, "first name": first_name, "last name": last_name, "semester type": self.sem_type, "profile_pic": img_url.absoluteString,"semester year": sem_year, "Instructing": self.inst_list, "Taking": self.student_list])
                                self.performSegue(withIdentifier: "register_success", sender: nil)
                            }
                        })
                    }
                })
            }else{
                self.alertMessage(title: "Oops!", message: "Please enter all fields!")
            }
        }else{
            self.alertMessage(title: "Oops!", message: "Please enter all fields!")
        }
        
        
    }
    
    
    
    
    
    
    /**
     ============================================== OTHER ===========================================================
     **/
    
    /*
     Create an alert message box
     */
    func alertMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /*
     Set the current active textfield that is being edited
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
    
    /*
     Dismiss keyboard when there is a tap gesture in the uiview
     */
    func dismiss_keyboard(gesture: UITapGestureRecognizer) {
        user_email.resignFirstResponder()
        user_fn.resignFirstResponder()
        user_ln.resignFirstResponder()
        user_pwd.resignFirstResponder()
        class_text.resignFirstResponder()
        for c in classes {
            c.resignFirstResponder()
        }
    }
    
    /*
     Function to get current year
     */
    func get_curr_year() -> Int{
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


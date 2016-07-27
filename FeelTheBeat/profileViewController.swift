//
//  profileViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/21/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

class profileViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtErrorMess: UILabel!
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldYearOfBirth: UITextField!
    @IBOutlet weak var txtFieldCountry: UITextField!
    @IBOutlet weak var txtFieldNewPassword: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnChangePassword: UIButton!
    var topConstraint = NSLayoutConstraint()
    var newTopConstraint = NSLayoutConstraint()
    var isChangePassword:Bool = false
    var isChangeAvatar:Bool = false
    
    @IBAction func btnSubmit(sender: AnyObject) {
        handleSubmit()
    }
    
    @IBAction func btnChangePassword(sender: AnyObject) {
        UIView.animateWithDuration(1, animations: {
            self.txtErrorMess.alpha = 0
            self.txtFieldEmail.alpha = 0
            self.txtFieldPassword.alpha = 0
            self.txtFieldUsername.alpha = 0
            self.txtFieldYearOfBirth.alpha = 0
            self.txtFieldCountry.alpha = 0
            self.txtFieldNewPassword.alpha = 0
            self.btnSubmit.alpha = 0
            self.btnChangePassword.alpha = 0
            self.imgLogo.alpha = 0
            self.btnMenu.alpha = 0
        }) { (animate) in
            if self.isChangePassword{
                self.isChangePassword = false
                self.txtFieldNewPassword.hidden = true
                self.newTopConstraint.active = false
                self.topConstraint.active = true
                self.btnChangePassword.setTitle("Đổi mật khẩu", forState: .Normal)
            }else{
                self.isChangePassword = true
                self.txtFieldNewPassword.hidden = false
                self.topConstraint.active = false
                self.newTopConstraint.active = true
                self.btnChangePassword.setTitle("Hủy đổi mật khẩu", forState: .Normal)
            }
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(1, animations: {
                self.txtErrorMess.alpha = 1
                self.txtFieldEmail.alpha = 1
                self.txtFieldPassword.alpha = 1
                self.txtFieldUsername.alpha = 1
                self.txtFieldYearOfBirth.alpha = 1
                self.txtFieldCountry.alpha = 1
                self.txtFieldNewPassword.alpha = 1
                self.btnSubmit.alpha = 1
                self.btnChangePassword.alpha = 1
                self.imgLogo.alpha = 1
                self.btnMenu.alpha = 1
            })
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSubmit.translatesAutoresizingMaskIntoConstraints = false
        //Add Top Constraint
        topConstraint = btnSubmit.topAnchor.constraintEqualToAnchor(txtFieldPassword.bottomAnchor, constant: 30)
        newTopConstraint = btnSubmit.topAnchor.constraintEqualToAnchor(txtFieldPassword.bottomAnchor, constant: 30 + 20 + txtFieldPassword.frame.height)
        topConstraint.active = true
        self.view.layoutIfNeeded()
        //Animation
        let viewBoxObj:[AnyObject] = [txtFieldEmail, txtFieldUsername, txtFieldCountry, txtFieldYearOfBirth, txtFieldPassword, txtFieldNewPassword, btnSubmit, btnChangePassword]
        var index = 0
        for obj in viewBoxObj{
            if let obj:UIButton = obj as? UIButton{
                UIView.animateWithDuration(2, delay: 0.1*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                    obj.bounds.origin.x += self.view.bounds.size.width
                    }, completion: nil)
            }else{
                if let obj:UITextField = obj as? UITextField{
                    UIView.animateWithDuration(2, delay: 0.1*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                        obj.bounds.origin.x += self.view.bounds.size.width
                        }, completion: nil)
                }
            }
            index += 1
        }
        //Customise button
        btnSubmit.ghostButton(5, borderWidth: 1, borderColor: UIColor.whiteColor())
        btnChangePassword.ghostButton(5, borderWidth: 1, borderColor: UIColor.whiteColor())
        //Customise text field
        txtFieldUsername.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Tên của bạn", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldPassword.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Xác nhận mật khẩu", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldEmail.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Email", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldYearOfBirth.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Ngày sinh", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldCountry.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Quê quán", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldNewPassword.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Mật khẩu mới", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        //Fill data to text field
        if userInfo.avatarURL != ""{
            imgLogo.loadImageFromUsingCache(userInfo.avatarURL)
        }else{
            imgLogo.image = UIImage(named: "defaultUserAvatar")
        }
        txtFieldEmail.userInteractionEnabled = false
        txtFieldEmail.text = userInfo.email
        txtFieldUsername.text = userInfo.fullName
        txtFieldCountry.text = (userInfo.country != "") ? userInfo.country : ""
        if userInfo.birthday != nil{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            txtFieldYearOfBirth.text = dateFormatter.stringFromDate(userInfo.birthday)
        }
        //Tap gesture
        imgLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
        imgLogo.userInteractionEnabled = true
        //Side bar menu
        let origImage = UIImage(named: "menuOn");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        btnMenu.setImage(tintedImage, forState: .Normal)
        btnMenu.tintColor = UIColor.whiteColor()
        if revealViewController() != nil {
            btnMenu.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        //Customise keyboard, UITextfield
        txtFieldEmail.delegate = self
        txtFieldPassword.delegate = self
        txtFieldUsername.delegate = self
        txtFieldNewPassword.delegate = self
        txtFieldCountry.delegate = self
        txtFieldYearOfBirth.delegate = self
        txtFieldEmail.returnKeyType = UIReturnKeyType.Done
        txtFieldEmail.enablesReturnKeyAutomatically = false
        txtFieldPassword.returnKeyType = UIReturnKeyType.Done
        txtFieldPassword.enablesReturnKeyAutomatically = false
        txtFieldUsername.returnKeyType = UIReturnKeyType.Done
        txtFieldUsername.enablesReturnKeyAutomatically = false
        txtFieldNewPassword.returnKeyType = UIReturnKeyType.Done
        txtFieldNewPassword.enablesReturnKeyAutomatically = false
        txtFieldCountry.returnKeyType = UIReturnKeyType.Done
        txtFieldCountry.enablesReturnKeyAutomatically = false
        txtFieldYearOfBirth.returnKeyType = UIReturnKeyType.Done
        txtFieldYearOfBirth.enablesReturnKeyAutomatically = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(profileViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(profileViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        scrollView.contentInset.bottom -= scrollView.contentInset.bottom
        scrollView.scrollIndicatorInsets.bottom -= scrollView.contentInset.bottom
        if show{
            let userInfo = notification.userInfo!
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            let changeInHeight = CGRectGetHeight(keyboardFrame)
            
            scrollView.contentInset.bottom += changeInHeight
            scrollView.scrollIndicatorInsets.bottom += changeInHeight
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

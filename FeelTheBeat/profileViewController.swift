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
    
    @IBAction func btnSubmit(_ sender: AnyObject) {
        handleSubmit()
    }
    
    @IBAction func btnChangePassword(_ sender: AnyObject) {
        UIView.animate(withDuration: 1, animations: {
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
        }, completion: { (animate) in
            if self.isChangePassword{
                self.isChangePassword = false
                self.txtFieldNewPassword.isHidden = true
                self.newTopConstraint.isActive = false
                self.topConstraint.isActive = true
                self.btnChangePassword.setTitle("Đổi mật khẩu", for: UIControlState())
            }else{
                self.isChangePassword = true
                self.txtFieldNewPassword.isHidden = false
                self.topConstraint.isActive = false
                self.newTopConstraint.isActive = true
                self.btnChangePassword.setTitle("Hủy đổi mật khẩu", for: UIControlState())
            }
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 1, animations: {
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
        }) 

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSubmit.translatesAutoresizingMaskIntoConstraints = false
        //Add Top Constraint
        topConstraint = btnSubmit.topAnchor.constraint(equalTo: txtFieldPassword.bottomAnchor, constant: 30)
        newTopConstraint = btnSubmit.topAnchor.constraint(equalTo: txtFieldPassword.bottomAnchor, constant: 30 + 20 + txtFieldPassword.frame.height)
        topConstraint.isActive = true
        self.view.layoutIfNeeded()
        //Animation
        let viewBoxObj:[AnyObject] = [txtFieldEmail, txtFieldUsername, txtFieldCountry, txtFieldYearOfBirth, txtFieldPassword, txtFieldNewPassword, btnSubmit, btnChangePassword]
        var index = 0
        for obj in viewBoxObj{
            if let obj:UIButton = obj as? UIButton{
                UIView.animate(withDuration: 2, delay: 0.1*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions(), animations: {
                    obj.bounds.origin.x += self.view.bounds.size.width
                    }, completion: nil)
            }else{
                if let obj:UITextField = obj as? UITextField{
                    UIView.animate(withDuration: 2, delay: 0.1*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                        obj.bounds.origin.x += self.view.bounds.size.width
                        }, completion: nil)
                }
            }
            index += 1
        }
        //Customise button
        btnSubmit.ghostButton(5, borderWidth: 1, borderColor: UIColor.white)
        btnChangePassword.ghostButton(5, borderWidth: 1, borderColor: UIColor.white)
        //Customise text field
        txtFieldUsername.customTextField(1, borderColor: UIColor.white, placeholderText: "Tên của bạn", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        txtFieldPassword.customTextField(1, borderColor: UIColor.white, placeholderText: "Xác nhận mật khẩu", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        txtFieldEmail.customTextField(1, borderColor: UIColor.white, placeholderText: "Email", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        txtFieldYearOfBirth.customTextField(1, borderColor: UIColor.white, placeholderText: "Ngày sinh", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        txtFieldCountry.customTextField(1, borderColor: UIColor.white, placeholderText: "Quê quán", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        txtFieldNewPassword.customTextField(1, borderColor: UIColor.white, placeholderText: "Mật khẩu mới", placeholderColor: UIColor.lightGray, paddingLeft: 10)
        //Fill data to text field
        if userInfo.avatarURL != ""{
            imgLogo.kf.setImage(with: URL(string: userInfo.avatarURL))
        }else{
            imgLogo.image = UIImage(named: "defaultUserAvatar")
        }
        txtFieldEmail.isUserInteractionEnabled = false
        txtFieldEmail.text = userInfo.email
        txtFieldUsername.text = userInfo.fullName
        txtFieldCountry.text = (userInfo.country != "") ? userInfo.country : ""
        if userInfo.birthday != nil{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            txtFieldYearOfBirth.text = dateFormatter.string(from: userInfo.birthday as Date)
        }
        //Tap gesture
        imgLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
        imgLogo.isUserInteractionEnabled = true
        //Side bar menu
        let origImage = UIImage(named: "menuOn");
        let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        btnMenu.setImage(tintedImage, for: UIControlState())
        btnMenu.tintColor = UIColor.white
        if revealViewController() != nil {
            btnMenu.addTarget(revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        //Customise keyboard, UITextfield
        txtFieldEmail.delegate = self
        txtFieldPassword.delegate = self
        txtFieldUsername.delegate = self
        txtFieldNewPassword.delegate = self
        txtFieldCountry.delegate = self
        txtFieldYearOfBirth.delegate = self
        txtFieldEmail.returnKeyType = UIReturnKeyType.done
        txtFieldEmail.enablesReturnKeyAutomatically = false
        txtFieldPassword.returnKeyType = UIReturnKeyType.done
        txtFieldPassword.enablesReturnKeyAutomatically = false
        txtFieldUsername.returnKeyType = UIReturnKeyType.done
        txtFieldUsername.enablesReturnKeyAutomatically = false
        txtFieldNewPassword.returnKeyType = UIReturnKeyType.done
        txtFieldNewPassword.enablesReturnKeyAutomatically = false
        txtFieldCountry.returnKeyType = UIReturnKeyType.done
        txtFieldCountry.enablesReturnKeyAutomatically = false
        txtFieldYearOfBirth.returnKeyType = UIReturnKeyType.done
        txtFieldYearOfBirth.enablesReturnKeyAutomatically = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(profileViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        scrollView.contentInset.bottom -= scrollView.contentInset.bottom
        scrollView.scrollIndicatorInsets.bottom -= scrollView.contentInset.bottom
        if show{
            let userInfo = notification.userInfo!
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let changeInHeight = keyboardFrame.height
            
            scrollView.contentInset.bottom += changeInHeight
            scrollView.scrollIndicatorInsets.bottom += changeInHeight
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}

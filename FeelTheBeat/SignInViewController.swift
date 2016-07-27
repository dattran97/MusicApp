//
//  SignInViewController.swift
//  FeelTheBeat
//
//  Created by Dat on 7/6/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var txtErrorMess: UILabel!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var txtFieldUsername: UITextField!
    @IBOutlet weak var txtFieldPassword: UITextField!
    @IBOutlet weak var txtFieldEmail: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    var topConstraint = NSLayoutConstraint()
    var newTopConstraint = NSLayoutConstraint()
    var isSignIn:Bool = true
     
    func changeDisplay(){
        UIView.animateWithDuration(1, animations: {
            self.txtErrorMess.alpha = 0
            self.txtFieldEmail.alpha = 0
            self.txtFieldPassword.alpha = 0
            self.txtFieldUsername.alpha = 0
            self.btnSignIn.alpha = 0
            self.btnSignUp.alpha = 0
            self.btnForgotPassword.alpha = 0
            self.imgLogo.alpha = 0
            self.btnMenu.alpha = 0
        }) { (animate) in
            if self.isSignIn == false{
                self.isSignIn = true
                self.txtFieldUsername.hidden = true
                self.newTopConstraint.active = false
                self.topConstraint.active = true
                self.imgLogo.image = UIImage(named: "avatar1x1")
                self.imgLogo.userInteractionEnabled = false
            }else{
                self.isSignIn = false
                self.txtFieldUsername.hidden = false
                self.topConstraint.active = false
                self.newTopConstraint.active = true
                //Tap imageView to change avatar
                self.imgLogo.image = UIImage(named: "defaultUserAvatar")
                self.txtErrorMess.text = "Chạm vào logo trên để thay đổi avatar"
                self.imgLogo.userInteractionEnabled = true
            }
            self.view.layoutIfNeeded()
            UIView.animateWithDuration(1, animations: {
                self.txtErrorMess.alpha = 1
                self.txtFieldEmail.alpha = 1
                self.txtFieldPassword.alpha = 1
                self.txtFieldUsername.alpha = 1
                self.btnSignIn.alpha = 1
                self.btnSignUp.alpha = 1
                self.btnForgotPassword.alpha = 1
                self.imgLogo.alpha = 1
                self.btnMenu.alpha = 1
            })
        }
    }
    @IBAction func btnSignIn(sender: AnyObject) {
        txtErrorMess.text = ""
        if isSignIn == false{
            changeDisplay()
        }else{
            handleLogIn()
        }
    }
    @IBAction func btnSignUp(sender: AnyObject) {
        txtErrorMess.text = ""
        if isSignIn{
            changeDisplay()
        }else{
            handleRegister()
        }
    }
    @IBAction func btnForgotPassword(sender: AnyObject) {
        handleForgotPassword()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(btnSignIn)
        btnSignIn.translatesAutoresizingMaskIntoConstraints = false
        //Add Top Constraint
        topConstraint = btnSignIn.topAnchor.constraintEqualToAnchor(txtFieldPassword.bottomAnchor, constant: 30)
        newTopConstraint = btnSignIn.topAnchor.constraintEqualToAnchor(txtFieldPassword.bottomAnchor, constant: 30 + 20 + txtFieldPassword.frame.height)
        topConstraint.active = true
        self.view.layoutIfNeeded()
        //Animation
        let viewBoxObj:[AnyObject] = [txtFieldEmail, txtFieldPassword, txtFieldUsername, btnSignIn, btnSignUp, btnForgotPassword]
        var index = 0
        for obj in viewBoxObj{
            if let obj:UIButton = obj as? UIButton{
                UIView.animateWithDuration(0.5, delay: 0.05*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                    obj.bounds.origin.x += self.view.bounds.size.width
                    }, completion: nil)
            }else{
                if let obj:UITextField = obj as? UITextField{
                    UIView.animateWithDuration(0.5, delay: 0.05*(Double)(index), usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                        obj.bounds.origin.x += self.view.bounds.size.width
                        }, completion: nil)
                }
            }
            index += 1
        }
        //Customise button
        btnSignIn.ghostButton(5, borderWidth: 1, borderColor: UIColor.whiteColor())
        btnSignUp.ghostButton(5, borderWidth: 1, borderColor: UIColor.whiteColor())
        //Customise text field
        txtFieldUsername.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Tên của bạn", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldPassword.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Mật khẩu", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        txtFieldEmail.customTextField(1, borderColor: UIColor.whiteColor(), placeholderText: "Email", placeholderColor: UIColor.lightGrayColor(), paddingLeft: 10)
        //Tap gesture
        imgLogo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeAvatar)))
        imgLogo.userInteractionEnabled = false
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
        txtFieldEmail.returnKeyType = UIReturnKeyType.Done
        txtFieldEmail.enablesReturnKeyAutomatically = false
        txtFieldPassword.returnKeyType = UIReturnKeyType.Done
        txtFieldPassword.enablesReturnKeyAutomatically = false
        txtFieldUsername.returnKeyType = UIReturnKeyType.Done
        txtFieldUsername.enablesReturnKeyAutomatically = false

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        //Log out
        handleLogOut()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        print(self.btnSignIn.frame.origin.y)
        if self.btnSignIn.frame.origin.y > self.view.frame.height - 150{
            self.view.frame.origin.y = -150
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

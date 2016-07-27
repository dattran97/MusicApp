//
//  handleSignInView.swift
//  FeelTheBeat
//
//  Created by Dat on 7/8/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

extension SignInViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //-------------------------------------Handle Log Out--------------------------------------
    func handleLogOut(){
        if (FIRAuth.auth()?.currentUser) != nil{
            try! FIRAuth.auth()!.signOut()
            userInfo = User()
            let appearance = SCLAlertView.SCLAppearance(
                kTitleTop: 30,
                kTitleHeight: 50,
                kWindowWidth: self.view.bounds.width * 8 / 10,
                showCloseButton: true
            )
            let successAlert = SCLAlertView(appearance: appearance)
            successAlert.addButton("Về trang chủ", action: {
                let homeView = self.storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController
                self.revealViewController().pushFrontViewController(homeView, animated: true)
            })
            successAlert.showSuccess("Thành công", subTitle: "Bạn đã đăng xuất thành công", closeButtonTitle: "Đăng nhập tài khoản khác", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
        }
    }
    //--------------------------------------Handle Log In--------------------------------------
    func handleLogIn(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: false
        )
        let errorAppearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: true
        )
        let waitingAlert = SCLAlertView(appearance: appearance)
        let errorAlert = SCLAlertView(appearance: errorAppearance)

        guard let email = txtFieldEmail.text, password = txtFieldPassword.text else{
            txtErrorMess.text = "Bạn chưa nhập đủ các thông tin"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        if email.isEmpty || password.isEmpty {
            txtErrorMess.text = "Bạn chưa nhập đủ các thông tin"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        //Show waiting alert
        waitingAlert.showWait("Chờ xíu...", subTitle: "", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
        
        //Firebase
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                if let errorCode = FIRAuthErrorCode(rawValue: (error?.code)!){
                    switch (errorCode){
                    case .ErrorCodeInvalidEmail:
                        self.txtErrorMess.text = "Địa chỉ email không chính xác"
                    case .ErrorCodeUserNotFound:
                        self.txtErrorMess.text = "Email này chưa được đăng kí trong hệ thống"
                    case .ErrorCodeWrongPassword:
                        self.txtErrorMess.text = "Mật khẩu không đúng"
                    case .ErrorCodeNetworkError:
                        self.txtErrorMess.text = "Vui lòng kiểm tra lại đường truyền internet"
                    default:
                        self.txtErrorMess.text = "Đã có lỗi trong quá trình đăng ký, vui lòng liên hệ BQT để được trợ giúp"
                    }
                }
                waitingAlert.hideView()
                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                return
            }
            //Success
            userInfo = User()
            waitingAlert.hideView()
            let successAlert = SCLAlertView(appearance: appearance)
            successAlert.addButton("Về trang chủ", action: {
                let homeView = self.storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController
                self.revealViewController().pushFrontViewController(homeView, animated: true)
            })
            successAlert.showSuccess("Thành công", subTitle: "Chào mừng bạn đã trờ lại với Scroby Music", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
        })
    }
    
//--------------------------------------Handle Register--------------------------------------
    func handleRegister(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: false
        )
        let errorAppearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: true
        )
        let waitingAlert = SCLAlertView(appearance: appearance)
        let errorAlert = SCLAlertView(appearance: errorAppearance)
        guard let email = txtFieldEmail.text, password = txtFieldPassword.text, name = txtFieldUsername.text else{
            txtErrorMess.text = "Bạn chưa nhập đủ các thông tin"
            errorAlert.showError("Lỗi", subTitle: txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        if email.isEmpty || password.isEmpty || name.isEmpty{
            txtErrorMess.text = "Bạn chưa nhập đủ các thông tin"
            errorAlert.showError("Lỗi", subTitle: txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        
        //Show waiting alert
        waitingAlert.showWait("Chờ xíu...", subTitle: "", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
        
        //Firebase
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
                    switch errorCode {
                    case .ErrorCodeInvalidEmail:
                        self.txtErrorMess.text = "Địa chỉ email không chính xác"
                    case .ErrorCodeEmailAlreadyInUse:
                        self.txtErrorMess.text = "Email này đã được đăng ký trước đây"
                    case .ErrorCodeWeakPassword:
                        self.txtErrorMess.text = "Hãy sử dụng password mạnh hơn"
                    case .ErrorCodeNetworkError:
                        self.txtErrorMess.text = "Vui lòng kiểm tra lại đường truyền internet"
                    default:
                        self.txtErrorMess.text = "Đã có lỗi trong quá trình đăng ký, vui lòng liên hệ BQT để được trợ giúp"
                    }
                }
                waitingAlert.hideView()
                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                return
            }
            guard let uid = user?.uid else{
                waitingAlert.hideView()
                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                return
            }
            //Success to create user in Auth
            
            //Upload avatar to Storage
            let storageRef = FIRStorage.storage().reference().child("UserAvatar").child("\(uid).png")
            //let uploadData = UIImagePNGRepresentation(self.imgLogo.image!)
            if let imageData = self.imgLogo.image, uploadData = UIImageJPEGRepresentation(imageData, 0.1){
                storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                    if error != nil{
                        self.txtErrorMess.text = "Không thể tải ảnh đại diện lên database"
                        waitingAlert.hideView()
                        errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                        return
                    }
                    if let imageURL = metaData?.downloadURL()?.absoluteString{
                        let value:[String:AnyObject] = ["email":email, "name":name, "birthday": "", "country": "", "avatar":imageURL]
                        //Add user info to database
                        let ref = FIRDatabase.database().reference()
                        ref.child("users").child(uid).updateChildValues(value, withCompletionBlock: { (error, ref) in
                            if error != nil{
                                self.txtErrorMess.text = "Không thể thêm user vào database"
                                waitingAlert.hideView()
                                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                                return
                            }
                            //Success to add user to database
                            waitingAlert.hideView()
                            let appearance = SCLAlertView.SCLAppearance(
                                kTitleTop: 30,
                                kTitleHeight: 50,
                                kWindowWidth: self.view.bounds.width * 8 / 10,
                                showCloseButton: false
                            )
                            let successAlert = SCLAlertView(appearance: appearance)
                            successAlert.addButton("Đăng nhập", action: {
                                self.txtErrorMess.text = ""
                                self.changeDisplay()
                            })
                            successAlert.showSuccess("Thành công", subTitle: "Chào mừng bạn đến với Scroby Music", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                        })
                    }
                })
            }

        })
    }
    //----------------------------------Handle forgot password--------------------------------------
    func handleForgotPassword(){
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: false
        )
        let errorAppearance = SCLAlertView.SCLAppearance(
            kTitleTop: 30,
            kTitleHeight: 50,
            kWindowWidth: self.view.bounds.width * 8 / 10,
            showCloseButton: true
        )
        let errorAlert = SCLAlertView(appearance: errorAppearance)
        let waitingAlert = SCLAlertView(appearance: appearance)
        let infoAlert = SCLAlertView(appearance: errorAppearance)
        let txtFieldEmail = infoAlert.addTextField()
        infoAlert.addButton("Gửi") {
            waitingAlert.showWait("Chờ xíu...", subTitle: "", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            FIRAuth.auth()?.sendPasswordResetWithEmail(txtFieldEmail.text!, completion: { (error) in
                if error != nil {
                    if let errorCode = FIRAuthErrorCode(rawValue: (error?.code)!){
                        switch (errorCode){
                        case .ErrorCodeUserNotFound:
                            self.txtErrorMess.text = "Email này chưa được sử dụng để đăng kí"
                        default:
                            self.txtErrorMess.text = "Đã có lỗi xảy ra, liên hệ BQT để được trợ giúp"
                        }
                        waitingAlert.hideView()
                        errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                        return
                    }
                } else {
                    waitingAlert.hideView()
                    let successAlert = SCLAlertView(appearance: errorAppearance)
                    successAlert.showSuccess("Thành công", subTitle: "Vui lòng kiểm tra email để khôi phục mật khẩu", closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                }
            })
        }
        infoAlert.showInfo("Nhập email", subTitle: "Chúng tôi sẽ gửi một email reset mật khẩu vào mail của bạn", closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
    }
    //--------------------------------------Change avatar-------------------------------------------
    func changeAvatar(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //Onclick cancel button
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImage:UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImage = editedImage
        }else{
            if let orginalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
                selectedImage = orginalImage
            }
        }
        if let selectedImage = selectedImage{
            imgLogo.image = selectedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}

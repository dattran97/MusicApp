//
//  handleProfileView.swift
//  FeelTheBeat
//
//  Created by Dat on 7/21/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

extension profileViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleSubmit(){
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
        
        var birthday:String!
        var country:String!
        var avatar:String!
        
        guard let password = txtFieldPassword.text where password.isEmpty == false else{
            txtErrorMess.text = "Hãy nhập mật khẩu xác nhận"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        
        if txtFieldUsername.text?.isEmpty == true {
            txtErrorMess.text = "Không thể bỏ trống khung Tên của bạn"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
            return
        }
        if txtFieldYearOfBirth.text?.isEmpty == false{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if dateFormatter.dateFromString(txtFieldYearOfBirth.text!) == nil{
                txtErrorMess.text = "Định dạng ngày không phù hợp"
                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text! + " (Định dạng phù hợp: dd/mm/yyyy)", closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                return
            }
            birthday = txtFieldYearOfBirth.text
        }else{
            birthday = ""
        }
    
        //Check password
        waitingAlert.showWait("Chờ xíu...", subTitle: "", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
        
        let user = FIRAuth.auth()?.currentUser
        let credential: FIRAuthCredential = FIREmailPasswordAuthProvider.credentialWithEmail(userInfo.email, password: password)
        // Prompt the user to re-provide their sign-in credentials
        
        user?.reauthenticateWithCredential(credential) { error in
            if error != nil {
                if let errorCode = FIRAuthErrorCode(rawValue: (error?.code)!){
                    switch (errorCode){
                    case .ErrorCodeWrongPassword:
                        self.txtErrorMess.text = "Mật khẩu không đúng"
                    default:
                        self.txtErrorMess.text = "Đã có lỗi xảy ra, liên hệ BQT để được trợ giúp"
                    }
                    waitingAlert.hideView()
                    errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                    return
                }
            }
            if self.isChangePassword{
                guard let newPassword = self.txtFieldNewPassword.text where newPassword.isEmpty == false else{
                    self.txtErrorMess.text = "Hãy nhập mật khẩu mới"
                    waitingAlert.hideView()
                    errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                    return
                }
                user?.updatePassword(newPassword, completion: { (error) in
                    if error != nil {
                        self.txtErrorMess.text = "Mật khẩu mới không phù hợp"
                        waitingAlert.hideView()
                        errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                        return
                    }
                })
            }
            
            let group = dispatch_group_create()
            dispatch_group_enter(group)
            if self.isChangeAvatar{
                //Upload avatar to Storage
                let storageRef = FIRStorage.storage().reference().child("UserAvatar").child("\(userInfo.uid).png")
                //let uploadData = UIImagePNGRepresentation(self.imgLogo.image!)
                if let imageData = self.imgLogo.image, uploadData = UIImageJPEGRepresentation(imageData, 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                        if error != nil{
                            self.txtErrorMess.text = "Không thể tải ảnh đại diện lên database"
                            waitingAlert.hideView()
                            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                            return
                        }
                        if let url = metaData?.downloadURL()?.absoluteString{
                            avatar = url
                            dispatch_group_leave(group)
                        }
                    })
                }
            }else{
                avatar = userInfo.avatarURL
                dispatch_group_leave(group)
            }
            dispatch_group_notify(group, dispatch_get_main_queue()) {
                country = (self.txtFieldCountry.text != nil) ? self.txtFieldCountry.text : ""

                let value:[String:AnyObject] = ["email":self.txtFieldEmail.text!, "name":self.txtFieldUsername.text!, "birthday": birthday, "country": country, "avatar":avatar]
                //Update user info
                let ref = FIRDatabase.database().reference()
                ref.child("users").child(userInfo.uid).updateChildValues(value) { (error, ref) in
                    if error != nil{
                        self.txtErrorMess.text = "Không thể cập nhật thông tin user vào database"
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
                    successAlert.addButton("Về trang chủ", action: {
                        let homeView = self.storyboard!.instantiateViewControllerWithIdentifier("containerView") as! ContainerViewController
                        self.revealViewController().pushFrontViewController(homeView, animated: true)
                    })
                    successAlert.showSuccess("Thành công", subTitle: "Đã cập nhật thông tin thành công", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .LeftToRight)
                }
                
            }
        }
    }
    //--------------------------------------Change avatar--------------------------------------
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
        isChangeAvatar = true
        dismissViewControllerAnimated(true, completion: nil)
    }
}

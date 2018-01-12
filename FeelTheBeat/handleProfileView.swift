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
        
        guard let password = txtFieldPassword.text, password.isEmpty == false else{
            txtErrorMess.text = "Hãy nhập mật khẩu xác nhận"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
            return
        }
        
        if txtFieldUsername.text?.isEmpty == true {
            txtErrorMess.text = "Không thể bỏ trống khung Tên của bạn"
            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
            return
        }
        if txtFieldYearOfBirth.text?.isEmpty == false{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if dateFormatter.date(from: txtFieldYearOfBirth.text!) == nil{
                txtErrorMess.text = "Định dạng ngày không phù hợp"
                errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text! + " (Định dạng phù hợp: dd/mm/yyyy)", closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                return
            }
            birthday = txtFieldYearOfBirth.text
        }else{
            birthday = ""
        }
    
        //Check password
        waitingAlert.showWait("Chờ xíu...", subTitle: "", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
        
        let user = Auth.auth().currentUser
        let credential: AuthCredential = FIREmailPasswordAuthProviderID.credentialWithEmail(userInfo.email, password: password)
        // Prompt the user to re-provide their sign-in credentials
        
        user?.reauthenticate(with: credential) { error in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: (error?._code)!){
                    switch (errorCode){
                    case .wrongPassword:
                        self.txtErrorMess.text = "Mật khẩu không đúng"
                    default:
                        self.txtErrorMess.text = "Đã có lỗi xảy ra, liên hệ BQT để được trợ giúp"
                    }
                    waitingAlert.hideView()
                    errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                    return
                }
            }
            if self.isChangePassword{
                guard let newPassword = self.txtFieldNewPassword.text, newPassword.isEmpty == false else{
                    self.txtErrorMess.text = "Hãy nhập mật khẩu mới"
                    waitingAlert.hideView()
                    errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                    return
                }
                user?.updatePassword(to: newPassword, completion: { (error) in
                    if error != nil {
                        self.txtErrorMess.text = "Mật khẩu mới không phù hợp"
                        waitingAlert.hideView()
                        errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                        return
                    }
                })
            }
            
            let group = DispatchGroup()
            group.enter()
            if self.isChangeAvatar{
                //Upload avatar to Storage
                let storageRef = Storage.storage().reference().child("UserAvatar").child("\(userInfo.uid).png")
                //let uploadData = UIImagePNGRepresentation(self.imgLogo.image!)
                if let imageData = self.imgLogo.image, let uploadData = UIImageJPEGRepresentation(imageData, 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                        if error != nil{
                            self.txtErrorMess.text = "Không thể tải ảnh đại diện lên database"
                            waitingAlert.hideView()
                            errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                            return
                        }
                        if let url = metaData?.downloadURL()?.absoluteString{
                            avatar = url
                            group.leave()
                        }
                    })
                }
            }else{
                avatar = userInfo.avatarURL
                group.leave()
            }
            dispatch_group_notify(group, DispatchQueue.main) {
                country = (self.txtFieldCountry.text != nil) ? self.txtFieldCountry.text : ""

                let value:[String:AnyObject] = ["email":self.txtFieldEmail.text! as AnyObject, "name":self.txtFieldUsername.text! as AnyObject, "birthday": birthday as AnyObject, "country": country as AnyObject, "avatar":avatar as AnyObject]
                //Update user info
                let ref = Database.database().reference()
                ref.child("users").child(userInfo.uid).updateChildValues(value) { (error, ref) in
                    if error != nil{
                        self.txtErrorMess.text = "Không thể cập nhật thông tin user vào database"
                        waitingAlert.hideView()
                        errorAlert.showError("Lỗi", subTitle: self.txtErrorMess.text!, closeButtonTitle: "Đóng", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
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
                        let homeView = self.storyboard!.instantiateViewController(withIdentifier: "containerView") as! ContainerViewController
                        self.revealViewController().pushFrontViewController(homeView, animated: true)
                    })
                    successAlert.showSuccess("Thành công", subTitle: "Đã cập nhật thông tin thành công", closeButtonTitle: "", duration: 0, colorStyle: 0, colorTextButton: 16777215, circleIconImage: nil, animationStyle: .leftToRight)
                }
                
            }
        }
    }
    //--------------------------------------Change avatar--------------------------------------
    func changeAvatar(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //Onclick cancel button
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
        dismiss(animated: true, completion: nil)
    }
}

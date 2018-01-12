//
//  supportExtensions.swift
//  FeelTheBeat
//
//  Created by Dat on 7/27/16.
//  Copyright © 2016 trantuandat. All rights reserved.
//

import UIKit

//-------------------------------------Shuffle array extension--------------------------------------
extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<Int(count) - 1 {
            let j = Int(arc4random_uniform(UInt32(Int(count) - i))) + i
            guard i != j else { continue }
            self.swapAt(i, j)
        }
    }
}
//------------------------UIColor with both image and color extension--------------------------------------
extension UIColor {
    static func imageWithBackgroundColor(_ image: UIImage, bgColor: UIColor) -> UIColor {
        let size = CGSize(width: 70, height: 70)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context?.setFillColor(bgColor.cgColor)
        context?.addRect(rectangle)
        context?.drawPath(using: .fill)
        
        context?.draw(image.cgImage!, in: rectangle)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: img!)
    }
}
//------------------------Return visible viewController-----------------------------
public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}
//----------------------------Ghost button-------------------------------
extension UIButton{
    func ghostButton(_ cornerRadius:CGFloat, borderWidth:CGFloat, borderColor:UIColor){
        //self.layer.u
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.tintColor = borderColor
        //self.layer.underl
    }
}
//-------------------------Custom UITextfield-----------------------------
extension UITextField{
    func customTextField(_ borderWidth:CGFloat, borderColor:UIColor, placeholderText:String, placeholderColor:UIColor, paddingLeft:CGFloat){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: placeholderColor])
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingLeft, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.always
    }
}
//------------------------Encode HTML String-----------------------------
extension String {
    init?(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
        ]
        let attributedString = try! NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        self.init(attributedString.string)
    }
}

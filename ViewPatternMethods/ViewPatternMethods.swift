//
//  ViewPatternMethods.swift
//  Ninox
//
//  Created by saeed on 07/05/2023.
//
import Foundation
import UIKit

class ViewPatternMethods {
    
    //get dasboard border to a view
    class func dashBorderView(theView : UIView){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = theView.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: theView.bounds).cgPath
        theView.layer.addSublayer(yourViewBorder)
    }
    
    //give orange background gradient
    class func orangeButtonBackground(theView: UIView) {
        //        let colorTop =  UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).cgColor
        //        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
        //
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradLayer"
        gradientLayer.colors = [
            UIColor(red: 1, green: 0.278, blue: 0.05, alpha: 1).cgColor,
            UIColor(red: 1, green: 0.48, blue: 0, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0.01, 0.79]
        gradientLayer.frame = theView.bounds
        
        theView.layer.insertSublayer(gradientLayer, at:0)
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
    }
    
    //up to down gradient
    class func upToDownGradient(theView: UIView){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = theView.bounds
        theView.layer.insertSublayer(gradientLayer, at:0)
        //        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        //        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
    }
    
    class func downToUpGradient(theView: UIView){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0).cgColor, UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = theView.bounds
        
        theView.layer.insertSublayer(gradientLayer, at:0)
        //        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        //        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
    }
    
    class func addShadowToView(theView: UIView){
        let shadowPath = UIBezierPath(rect: theView.bounds)
        theView.layer.masksToBounds = false;
        theView.layer.shadowColor = UIColor.black.cgColor
        theView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        theView.layer.shadowRadius = 2.0
        theView.layer.shadowOpacity = 0.2
        theView.layer.shadowPath = shadowPath.cgPath;
    }
    
    class func dropShadow(theView: UIView, color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        theView.layer.masksToBounds = false
        theView.layer.shadowColor = color.cgColor
        theView.layer.shadowOpacity = opacity
        theView.layer.shadowOffset = offSet
        theView.layer.shadowRadius = radius
        
        theView.layer.shadowPath = UIBezierPath(rect: theView.bounds).cgPath
        theView.layer.shouldRasterize = true
        theView.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    class func waitingDialog(controller: UIViewController)->UIAlertController{
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        controller.present(alert, animated: true, completion: nil)
        return alert
    }
    
    
    class func showAlert(controller: UIViewController, title: String, message: String)->UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }
        }))
        controller.present(alert, animated: true, completion: nil)
        return alert
    }
    
    
}

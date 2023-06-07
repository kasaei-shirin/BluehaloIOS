//
//  ViewClasses.swift
//  Ninox
//
//  Created by saeed on 05/06/2023.
//

import Foundation

import UIKit


class HeaderView: UIView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.backgroundColor = UIColor(named: "header")
        updateConstraint(attribute: .height, constant: 60)
    }
}

class PopupConfirmButton: UIButton{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.configuration?.background.backgroundColor = UIColor(named: "navy_blue")
        self.tintColor = UIColor(named: "navy_blue")
        updateConstraint(attribute: .height, constant: 42)
    }
}

class PopupCancelButton: UIButton{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.configuration?.background.backgroundColor = UIColor(named: "navy_blue")
        self.tintColor = UIColor(named: "navy_blue")
        updateConstraint(attribute: .height, constant: 42)
    }
}

class CommonButton: UIButton{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.tintColor = UIColor(named: "navy_back")
        self.configuration?.background.backgroundColor = UIColor(named: "navy_back")
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        updateConstraint(attribute: .height, constant: 42)
    }
    
}

extension UIView {
    
    func updateConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = constant
            self.layoutIfNeeded()
        }
    }
}


class HeaderLabel: UILabel{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
    }
}

class ContextTitleLabel: UILabel{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
    }
}

class ContextContentLabel: UILabel{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
    }
}


class BackImage: UIImageView{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(from: "coder")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(from: "frame")
    }
    
    func commonInit(from: String){
        self.alpha = 0.15
        self.backgroundColor = UIColor(named: "main_background")
        self.tintColor = UIColor(named: "pattern_tint")
    }
}




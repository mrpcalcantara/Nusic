//
//  UIViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        self.view.resignFirstResponder()
    }
    
    
    func addSwipeGestureRecognizers(){
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeBack(sender:)))
        leftGesture.direction = .left
        self.view.addGestureRecognizer(leftGesture)
    }
    
    @objc func swipeBack(sender:UISwipeGestureRecognizer?) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func disableUserInteraction() {
        self.view.isUserInteractionEnabled = false
    }
    
    func enableUserInteraction() {
        self.view.isUserInteractionEnabled = true
    }
    
    func delay(seconds: Double, completion: @escaping () -> ()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    func setBackButton(image: UIImage) {
        let btnLeftMenu: UIButton = UIButton()
        btnLeftMenu.setImage(image, for: .normal)
        btnLeftMenu.addTarget(self, action: #selector(self.swipeBack(sender:)), for: UIControlEvents.touchUpInside)
        //let navigationBar = self.navigationItem.backBarButtonItem.
        //btnLeftMenu.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.width)!, height: (self.navigationController?.navigationBar.frame.height)!)
        let barButton = UIBarButtonItem(customView: btnLeftMenu)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
}

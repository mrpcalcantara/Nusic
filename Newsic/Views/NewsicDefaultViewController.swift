//
//  NusicDefaultViewController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog
import SwiftSpinner

class NusicDefaultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoginErrorPopup() {
        SwiftSpinner.hide()
        let popupDialog = PopupDialog(title: "Error", message: "Unable to connect. Please, try to login again.")
        popupDialog.transitionStyle = .zoomIn
        
        
        let okButton = DefaultButton(title: "OK", action: {
//            print("Back to Login menu");
            self.dismiss(animated: true, completion: {
                SPTAuth.defaultInstance().resetCurrentLogin()
            })
//            self.dismiss(animated: true, completion: nil);
        })
        
        popupDialog.addButton(okButton);
        self.present(popupDialog, animated: true, completion: nil)
    }
    
    func goToPreviousViewController() {
        if let parent = self.parent as? NusicPageViewController {
            parent.scrollToPreviousViewController()
        }
    }
    
    func goToNextViewController() {
        if let parent = self.parent as? NusicPageViewController {
            parent.scrollToNextViewController()
        }
    }
}

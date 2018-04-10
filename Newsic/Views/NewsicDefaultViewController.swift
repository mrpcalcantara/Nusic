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
    
    private static let insetBackgroundViewTag = 98721 //Cool number

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("MEMORY WARNING AT VC = \(self.className)")
    }
    
    final func showLoginErrorPopup() {
        SwiftSpinner.hide()
        let popupDialog = PopupDialog(title: "Error", message: "Unable to connect. Please, try to login again.")
        popupDialog.transitionStyle = .zoomIn
        
        
        let okButton = DefaultButton(title: "OK", action: {
            self.dismiss(animated: true, completion: {
                SPTAuth.defaultInstance().resetCurrentLogin()
            })
        })
        
        popupDialog.addButton(okButton);
        self.present(popupDialog, animated: true, completion: nil)
    }
    
    final func goToPreviousViewController() {
        guard let parent = self.parent as? NusicPageViewController else { return }
        parent.scrollToPreviousViewController()
    }
    
    final func goToNextViewController() {
        guard let parent = self.parent as? NusicPageViewController else { return }
        parent.scrollToNextViewController()
    }
}

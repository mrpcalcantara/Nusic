//
//  NewsicErrorHandler.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import PopupDialog

class NewsicError: NSObject, Error {
    
    var newsicErrorCode: NewsicErrorCodes?
    var newsicErrorSubCode: NewsicErrorSubCode?
    var newsicErrorDescription: String?
    var systemError: Error?
    var popupDialog: PopupDialog?
    
    init(newsicErrorCode: NewsicErrorCodes?, newsicErrorSubCode: NewsicErrorSubCode?, newsicErrorDescription: String? = nil, systemError: Error? = nil) {
        super.init()
        self.newsicErrorCode = newsicErrorCode
        self.newsicErrorSubCode = newsicErrorSubCode
        self.newsicErrorDescription = newsicErrorDescription
        self.systemError = systemError
        //self.popupDialog = setupDialog();
    }
    
    func setupDialog(description: String? = nil) -> PopupDialog {
        var popupMessage = ""
        popupMessage.append("Error \(codesToString())")
        if let description = self.newsicErrorDescription {
            popupMessage.append(" - "); popupMessage.append(description)
        }
        else if let description = description  {
            popupMessage.append(" - "); popupMessage.append(description)
        } else {
            
        }
        
        let dialog = PopupDialog(title: "Error!", message: popupMessage, gestureDismissal: false)
        dialog.transitionStyle = .zoomIn
        
        let okButton = DefaultButton(title: "Got it!") {
            self.popupDialog?.dismiss(animated: true, completion: nil)
        }
        
        dialog.addButton(okButton);
        
        return dialog
    }
    
    func presentPopup(for viewController: UIViewController, description: String? = nil) {
        if self.popupDialog == nil {
            self.popupDialog = setupDialog(description: description)
        }
        if let popupDialog = self.popupDialog {
            viewController.present(popupDialog, animated: true, completion: nil);
        }
        
    }

    func codesToString() -> String {
        if let newsicErrorCode = newsicErrorCode, let newsicErrorSubCode = newsicErrorSubCode {
            return "\(newsicErrorCode.rawValue)\(newsicErrorSubCode.rawValue)"
        }
        return ""
    }
    
}

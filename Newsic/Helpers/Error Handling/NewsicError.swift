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
    var popupDialog: PopupDialog?
    
    init(newsicErrorCode: NewsicErrorCodes?, newsicErrorSubCode: NewsicErrorSubCode?, newsicErrorDescription: String? = "") {
        super.init()
        self.newsicErrorCode = newsicErrorCode
        self.newsicErrorSubCode = newsicErrorSubCode
        self.newsicErrorDescription = newsicErrorDescription
        //self.popupDialog = setupDialog();
    }
    
    func setupDialog(description: String? = nil) -> PopupDialog {
        var popupMessage = ""
        if newsicErrorCode == NewsicErrorCodes.spotifyError {
            
            if newsicErrorSubCode == NewsicErrorSubCode.serverError {
                popupMessage = "An error occured communicating with Spotify. Please try again."
            } else if newsicErrorSubCode == NewsicErrorSubCode.clientError {
                popupMessage = "An internal error occured. Please try again."
            }
        }
        
        if let description = description {
            popupMessage.append(" "); popupMessage.append(description)
        }
        
        let dialog = PopupDialog(title: "Error!", message: popupMessage, gestureDismissal: false)
//        dialog.transitionStyle = .zoomIn
        dialog.transitionStyle = .fadeIn
        
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

    
}

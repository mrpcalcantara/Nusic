//
//  NusicErrorHandler.swift
//  Nusic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import PopupDialog

class NusicError: NSObject, Error {
    
    var nusicErrorCode: NusicErrorCodes?
    var nusicErrorSubCode: NusicErrorSubCode?
    var nusicErrorDescription: String?
    var systemError: Error?
    var popupDialog: PopupDialog?
    
    init(nusicErrorCode: NusicErrorCodes?, nusicErrorSubCode: NusicErrorSubCode?, nusicErrorDescription: String? = nil, systemError: Error? = nil) {
        super.init()
        self.nusicErrorCode = nusicErrorCode
        self.nusicErrorSubCode = nusicErrorSubCode
        self.nusicErrorDescription = nusicErrorDescription
        self.systemError = systemError
    }
    
    private func setupDialog(description: String? = nil) -> PopupDialog {
        var popupMessage = ""
        popupMessage.append("Error \(codesToString())")
        if let description = self.nusicErrorDescription {
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
    
    final func presentPopup(for viewController: UIViewController, description: String? = nil) {
        if self.popupDialog == nil {
            self.popupDialog = setupDialog(description: description)
        }
        if let popupDialog = self.popupDialog {
            viewController.present(popupDialog, animated: true, completion: nil);
        }
        
    }

    final func codesToString() -> String {
        if let nusicErrorCode = nusicErrorCode, let nusicErrorSubCode = nusicErrorSubCode {
            return "\(nusicErrorCode.rawValue)\(nusicErrorSubCode.rawValue)"
        }
        return ""
    }
    
    static func manageError(statusCode: Int, errorCode: NusicErrorCodes) -> NusicError {
        switch statusCode {
        case 400...499:
            return NusicError(nusicErrorCode: errorCode, nusicErrorSubCode: NusicErrorSubCode.clientError)
        case 500...599:
            return NusicError(nusicErrorCode: errorCode, nusicErrorSubCode: NusicErrorSubCode.serverError)
        default:
            return NusicError(nusicErrorCode: errorCode, nusicErrorSubCode: NusicErrorSubCode.technicalError)
        }
    }
    
}

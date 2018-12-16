//
//  UITableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog
import SafariServices
import MessageUI
import SwiftSpinner

extension SideMenuViewController {
    final func setupTableView() {
        settingsTableView.delegate = self;
        settingsTableView.dataSource = self;
        settingsTableView.backgroundColor = UIColor.clear
        
        let view = UINib(nibName: SettingsCell.className, bundle: nil);
        settingsTableView.register(view, forCellReuseIdentifier: SettingsCell.reuseIdentifier);
        
        let headerView = UINib(nibName: SettingsHeader.className, bundle: nil);
        settingsTableView.register(headerView, forHeaderFooterViewReuseIdentifier: SettingsHeader.reuseIdentifier)
        
        //Remove remainder lines
        settingsTableView.tableFooterView = UIView()
        
        let header = SettingsHeader(frame: CGRect(x: settingsTableView.frame.origin.x, y: settingsTableView.frame.origin.y, width: settingsTableView.frame.width, height: 200))
        
        settingsTableView.backgroundColor = UIColor.clear
        guard let username = username else { return }
        header.configure(image: nil, imageURL: profileImageURL?.absoluteString, username: username)
        settingsTableView.tableHeaderView = header
    }
}

extension SideMenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let title = settingsValues[indexPath.section][0]
        switch title {
        case NusicSettingsLabel.contactMe.rawValue:
            cell.accessoryType = .none
        case NusicSettingsLabel.logout.rawValue:
            cell.accessoryType = .none
        case NusicSettingsLabel.privacyPolicy.rawValue:
            cell.accessoryType = .none
        default:
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        if indexPath.section == 0 && !enablePlayerSwitch! {
            let popup = PopupDialog(title: "Sorry!", message: "It appears you're not a Spotify Premium user. As such, you can only use the YouTube player.")
            popup.addButton(DefaultButton(title: "Got It!", action: nil))
            self.present(popup, animated: true, completion: nil)
        } else {
            cell.alertController?.show()
        }
        tableView.deselectRow(at: indexPath, animated: true)
//        cell.setSelected(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsCellHeader.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingsCellHeader(frame: CGRect(x: settingsTableView.frame.origin.x, y: settingsTableView.frame.origin.y, width: settingsTableView.frame.width, height: 80))
        let headerTitle = settingsValues[section][0]
        
        switch headerTitle {
        case NusicSettingsLabel.preferredPlayer.rawValue:
            header.headerLabel.text = NusicSettingsTitle.playerSettings.rawValue
        case NusicSettingsLabel.useMobileData.rawValue:
            header.headerLabel.text = NusicSettingsTitle.connectionSettings.rawValue
        case NusicSettingsLabel.privacyPolicy.rawValue:
            header.headerLabel.text = NusicSettingsTitle.infoSettings.rawValue
        case NusicSettingsLabel.contactMe.rawValue:
            header.headerLabel.text = NusicSettingsTitle.feedbackSettings.rawValue
        case NusicSettingsLabel.logout.rawValue:
            header.headerLabel.text = NusicSettingsTitle.actionSettings.rawValue
        case NusicSettingsLabel.spotifyQuality.rawValue:
            header.headerLabel.text = NusicSettingsTitle.spotifySettings.rawValue
        default:
            header.headerLabel.text = ""
        }
        return header;
    }
    
}

extension SideMenuViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsValues.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsValues[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell else { fatalError("Unexpected Table View Cell") }
        
        let title = settingsValues[indexPath.section][indexPath.row]
        switch title {
        case NusicSettingsLabel.preferredPlayer.rawValue:
            setupPlayerSettings(for: cell, title: title)
        case NusicSettingsLabel.spotifyQuality.rawValue:
            setupSpotifySettings(for: cell, title: title)
        case NusicSettingsLabel.useMobileData.rawValue:
            setupConnectionSettings(for: cell, title: title)
        case NusicSettingsLabel.logout.rawValue:
            setupActionSettings(for: cell, title: title)
        case NusicSettingsLabel.deleteAccount.rawValue:
            setupDeleteAccountSettings(for: cell, title: title)
        case NusicSettingsLabel.privacyPolicy.rawValue:
            setupInfoSettings(for: cell, title: title)
        case NusicSettingsLabel.contactMe.rawValue:
            setupContactSettings(for: cell, title: title)
        case NusicSettingsLabel.rateApp.rawValue:
            setupRatingSettings(for: cell, title: title)
        default:
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension SideMenuViewController {
    
    //Setup functions for Table View cells and sections
    fileprivate func setupPlayerSettings(for cell: SettingsCell, title: String) {
        guard let value = settings?.preferredPlayer?.rawValue, let str = NusicPreferredPlayer(rawValue: value) else { return; }
        let buttonSpotify = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifyIconHighlighted"), text: NusicPreferredPlayer.spotify.description())
        let actionSpotify = { () -> Void in
            self.settings?.preferredPlayer = NusicPreferredPlayer.spotify
            cell.itemValue.text = buttonSpotify.textLabel.text
            if !self.settingsValues.contains(where: { (array) -> Bool in
                return array.contains(NusicSettingsLabel.spotifyQuality.rawValue)
            }) {
                self.settingsValues.insert([NusicSettingsLabel.spotifyQuality.rawValue], at: 1)
                self.settingsTableView.reloadData()
            }
        }
        buttonSpotify.action = actionSpotify
        
        let buttonYoutube = YBButton(frame: CGRect.zero, icon: UIImage(named: "YoutubeIconHighlighted"), text: NusicPreferredPlayer.youtube.description())
        let actionYoutube = { () -> Void in
            self.settings?.preferredPlayer = NusicPreferredPlayer.youtube
            cell.itemValue.text = buttonYoutube.textLabel.text
            if let index = self.settingsValues.index(where: { (array) -> Bool in
                return array.contains(NusicSettingsLabel.spotifyQuality.rawValue)
            }) {
                self.settingsValues.remove(at: index)
                self.settingsTableView.reloadData()
            }
        }
        buttonYoutube.action = actionYoutube
        
        cell.configure(title: title, value: str.description(), icon: UIImage(named: "PreferredPlayer"))
        cell.alertController?.configure(options: [buttonSpotify, buttonYoutube])
    }
    
    fileprivate func setupConnectionSettings(for cell: SettingsCell, title: String) {
        guard let useMobileData = settings?.useMobileData else { return; }
        let buttonOn = YBButton(frame: CGRect.zero, icon: UIImage(named: "CheckmarkIcon"), text: (true).toString())
        let actionOn = { () -> Void in
            self.settings?.useMobileData = true
            cell.itemValue.text = buttonOn.textLabel.text
        }
        buttonOn.action = actionOn
        
        let buttonOff = YBButton(frame: CGRect.zero, icon: UIImage(named: "WrongIcon"), text: (false).toString())
        let actionOff = { () -> Void in
            self.settings?.useMobileData = false
            cell.itemValue.text = buttonOff.textLabel.text
        }
        buttonOff.action = actionOff
        
        cell.configure(title: title, value: useMobileData.toString(), icon: UIImage(named: "MobileData"))
        cell.alertController?.configure(options: [buttonOn, buttonOff])
        
    }
    
    fileprivate func setupActionSettings(for cell: SettingsCell, title: String) {
        let buttonLogout = YBButton(frame: CGRect.zero, icon: UIImage(named: "CheckmarkIcon"), text: "Yes")
        let actionLogout = { () -> Void in
            self.logoutUser()
            cell.itemValue.text = buttonLogout.textLabel.text
        }
        buttonLogout.action = actionLogout
        
        let buttonDismiss = YBButton(frame: CGRect.zero, icon: UIImage(named: "WrongIcon"), text: "No")
        let actionDismiss = { () -> Void in
            cell.alertController?.dismiss()
        }
        buttonDismiss.action = actionDismiss
        
        cell.configure(title: title, value: "", icon: nil, centerText: true)
        cell.alertController?.configure(options: [buttonLogout, buttonDismiss], alertText: "Are you sure?")
        
    }
    
    fileprivate func setupDeleteAccountSettings(for cell: SettingsCell, title: String) {
        let buttonDismiss = YBButton(frame: CGRect.zero, icon: UIImage(named: "WrongIcon"), text: "No")
        let actionDismiss = { () -> Void in
            cell.alertController?.dismiss()
        }
        buttonDismiss.action = actionDismiss
        
        let buttonDeleteAccount = YBButton(frame: CGRect.zero, icon: UIImage(named: "CheckmarkIcon"), text: "Yes")
        
        let actionDelete: () -> Void = {
            cell.alertController?.dismiss()
            let actionConfirmDelete = { () -> Void in
                self.nusicUser?.deleteUser(deleteUserHandler: { (isDeleted, error) in
                    guard error == nil else { error?.presentPopup(for: self); return; }
                    self.logoutUser();
                })
            }
            buttonDeleteAccount.action = actionConfirmDelete
            
            let basedOnAlertController = NusicAlertController(title: "Are you REALLY sure?", message: nil, style: YBAlertControllerStyle.ActionSheet)
            basedOnAlertController.addButton(icon: #imageLiteral(resourceName: "CheckmarkIcon"), title: "Yes, REALLY!", action: actionConfirmDelete)
            basedOnAlertController.addButton(icon: #imageLiteral(resourceName: "WrongIcon"), title: "No, not really..", action: actionDismiss)
            cell.alertController?.dismissCompletion({ (isCompleted) in
                basedOnAlertController.show()
            })
        }
        
        buttonDeleteAccount.action = actionDelete
        
        cell.configure(title: title, value: "", icon: nil, centerText: true)
        cell.alertController?.configure(options: [buttonDeleteAccount, buttonDismiss], alertText: "Are you sure? Deleting your account is definitive.")
        cell.itemDescription.textColor = UIColor.red
    }
    
    fileprivate func setupSpotifySettings(for cell: SettingsCell, title: String) {
        guard let bitrate = settings?.spotifySettings?.bitrate else { return; }
        let buttonHigh = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifySoundQualityHigh"), text: SPTBitrate.high.description())
        let actionHigh = { () -> Void in
            self.settings?.spotifySettings?.bitrate = .high
            cell.itemValue.text = buttonHigh.textLabel.text
        }
        buttonHigh.action = actionHigh
        
        let buttonNormal = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifySoundQualityMedium"), text: SPTBitrate.normal.description())
        let actionNormal = { () -> Void in
            self.settings?.spotifySettings?.bitrate = .normal
            cell.itemValue.text = buttonNormal.textLabel.text
        }
        buttonNormal.action = actionNormal
        
        let buttonLow = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifySoundQualityLow"), text: SPTBitrate.low.description())
        let actionLow = { () -> Void in
            self.settings?.spotifySettings?.bitrate = .low
            cell.itemValue.text = buttonLow.textLabel.text
        }
        buttonLow.action = actionLow
        
        cell.configure(title: title, value: bitrate.description(), icon: UIImage(named: "SpotifySoundQuality"))
        cell.alertController?.configure(options: [buttonHigh, buttonNormal, buttonLow])
        
    }
    
    fileprivate func setupInfoSettings(for cell: SettingsCell, title: String) {
        let buttonPrivacyPolicy = YBButton(frame: CGRect.zero, icon: #imageLiteral(resourceName: "ButtonAppIcon"), text: "Read the privacy policy")
        let actionPrivacyPolicy = { () -> Void in
            if let url = URL(string: "https://www.iubenda.com/privacy-policy/81210825") {
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            }
            
        }
        buttonPrivacyPolicy.action = actionPrivacyPolicy
        
        cell.configure(title: title, value: "", icon: nil, centerText: true)
        cell.alertController?.configure(options: [buttonPrivacyPolicy], alertText: "")
    }
    
    fileprivate func setupContactSettings(for cell: SettingsCell, title: String) {
        let buttonContact = YBButton(frame: CGRect.zero, icon: #imageLiteral(resourceName: "ButtonAppIcon"), text: "Contact me!")
        let actionContact = { () -> Void in
            self.sendEmail()
        }
        buttonContact.action = actionContact
        
        cell.configure(title: title, value: "", icon: nil, centerText: true)
        cell.alertController?.configure(options: [buttonContact], alertText: "")
    }
    
    fileprivate func setupRatingSettings(for cell: SettingsCell, title: String) {
        let buttonContact = YBButton(frame: CGRect.zero, icon: #imageLiteral(resourceName: "ButtonAppIcon"), text: "Rate the app!")
        let actionContact = { () -> Void in
            guard let url = URL(string: "https://itunes.apple.com/us/app/nusic/id1314807539?ls=1&mt=8&action=write-review") else { return }
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        buttonContact.action = actionContact
        
        cell.configure(title: title, value: "", icon: nil, centerText: true)
        cell.alertController?.configure(options: [buttonContact], alertText: "")
    }

    
}

extension SideMenuViewController: MFMailComposeViewControllerDelegate {
    fileprivate func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["malcantara.fl@gmail.com"])
            mail.setSubject("#Nusic iOS")
            let bodyText = ""
            mail.setMessageBody(bodyText, isHTML: false)
            present(mail, animated: true)
        } else {
            guard let url = URL(string: "mailto:malcantara.fl@gmail.com?subject=Nusic") else { showErrorPopup(); return; }
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    fileprivate func showErrorPopup() {
        let popupDialog = PopupDialog(title: "Error", message: "Something went wrong while opening the Mail app. Please contact me at malcantara.fl@gmail.com")
        popupDialog.transitionStyle = .zoomIn
        
        
        let okButton = DefaultButton(title: "OK", action: {
            self.dismiss(animated: true, completion: nil)
        })
        
        popupDialog.addButton(okButton);
        self.present(popupDialog, animated: true, completion: nil)
    }
    
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            SwiftSpinner.show(duration: 1, title: "Sent!")
        default:
            print("Cancelled")
        }
        
        controller.dismiss(animated: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

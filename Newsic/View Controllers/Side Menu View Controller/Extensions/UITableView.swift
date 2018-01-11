//
//  UITableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog

extension SideMenuViewController {
    func setupTableView() {
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
        
        header.configure(image: nil, imageURL: profileImageURL?.absoluteString, username: username!)
        
        settingsTableView.tableHeaderView = header
        settingsTableView.backgroundColor = UIColor.clear

    }
}

extension SideMenuViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if settingsValues[indexPath.section][0] == NusicSettingsLabel.logout.rawValue {
            cell.accessoryType = .none
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
        cell.setSelected(false, animated: true)
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
        
        let title = settingsValues[indexPath.section][0]
        switch title {
        case NusicSettingsLabel.preferredPlayer.rawValue:
            setupPlayerSettings(for: cell, title: title)
        case NusicSettingsLabel.spotifyQuality.rawValue:
            setupSpotifySettings(for: cell, title: title)
        case NusicSettingsLabel.useMobileData.rawValue:
            setupConnectionSettings(for: cell, title: title)
        case NusicSettingsLabel.logout.rawValue:
            setupActionSettings(for: cell, title: title)
            
            
        default:
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension SideMenuViewController {
    
    //Setup functions for Table View cells and sections
    func setupPlayerSettings(for cell: SettingsCell, title: String) {
        if let value = settings?.preferredPlayer?.rawValue {
            if let str = NusicPreferredPlayer(rawValue: value) {
                
                let buttonSpotify = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifyIconHighlighted"), text: NusicPreferredPlayer.spotify.description())
                let actionSpotify = { () -> Void in
                    self.settings?.preferredPlayer = NusicPreferredPlayer.spotify
                    cell.itemValue.text = buttonSpotify.textLabel.text
                }
                buttonSpotify.action = actionSpotify
                
                let buttonYoutube = YBButton(frame: CGRect.zero, icon: UIImage(named: "YoutubeIconHighlighted"), text: NusicPreferredPlayer.youtube.description())
                let actionYoutube = { () -> Void in
                    self.settings?.preferredPlayer = NusicPreferredPlayer.youtube
                    cell.itemValue.text = buttonYoutube.textLabel.text
                }
                buttonYoutube.action = actionYoutube
                
                cell.configureCell(title: title, value: str.description(), icon: UIImage(named: "PreferredPlayer"), options: [buttonSpotify, buttonYoutube], enableCell: enablePlayerSwitch!)
                
            }
        }
    }
    
    func setupConnectionSettings(for cell: SettingsCell, title: String) {
        if let useMobileData = settings?.useMobileData {
            
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
            
            cell.configureCell(title: title, value: useMobileData.toString(), icon: UIImage(named: "MobileData"), options: [buttonOn, buttonOff])
        }
    }
    
    func setupActionSettings(for cell: SettingsCell, title: String) {
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
        
        cell.configureCell(title: title, value: "", icon: nil, options: [buttonLogout, buttonDismiss], centerText: true, alertText: "Are you sure?")
        
    }
    
    func setupSpotifySettings(for cell: SettingsCell, title: String) {
        if let bitrate = settings?.spotifySettings?.bitrate {
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
            
            cell.configureCell(title: title, value: bitrate.description(), icon: UIImage(named: "SpotifySoundQuality"), options: [buttonHigh, buttonNormal, buttonLow])
        }
    }
    
}

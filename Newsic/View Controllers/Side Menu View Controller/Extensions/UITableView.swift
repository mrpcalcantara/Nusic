//
//  UITableView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SideMenuViewController2 {
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
        
//        settingsTableView.estimatedSectionHeaderHeight = 150
//        settingsTableView.estimatedRowHeight = 40
//        settingsTableView.rowHeight = UITableViewAutomaticDimension
        settingsTableView.backgroundColor = UIColor.clear
//        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
//        settingsTableView.addBlurEffect(style: .dark, alpha: 0.8)
    }
}

extension SideMenuViewController2 : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if settingsValues[indexPath.section][0] == NewsicSettingsLabel.logout.rawValue {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        cell.alertController?.show()
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
        
        
        print("headerTitle = \(headerTitle)")
        switch headerTitle {
        case NewsicSettingsLabel.preferredPlayer.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.playerSettings.rawValue
        case NewsicSettingsLabel.useMobileData.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.connectionSettings.rawValue
        case NewsicSettingsLabel.logout.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.actionSettings.rawValue
        case NewsicSettingsLabel.spotifyQuality.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.spotifySettings.rawValue
        default:
            header.headerLabel.text = ""
        }
        return header;
    }
    
}

extension SideMenuViewController2 : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsValues.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsValues[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell else { fatalError("Unexpected Table View Cell") }
        
        let title = settingsValues[indexPath.section][0]
        print(title)
        switch title {
        case NewsicSettingsLabel.preferredPlayer.rawValue:
            setupPlayerSettings(for: cell, title: title)
        case NewsicSettingsLabel.spotifyQuality.rawValue:
            setupSpotifySettings(for: cell, title: title)
        case NewsicSettingsLabel.useMobileData.rawValue:
            setupConnectionSettings(for: cell, title: title)
        case NewsicSettingsLabel.logout.rawValue:
            setupActionSettings(for: cell, title: title)
            
            
        default:
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension SideMenuViewController2 {
    
    //Setup functions for Table View cells and sections
    func setupPlayerSettings(for cell: SettingsCell, title: String) {
        if let value = settings?.preferredPlayer?.rawValue {
            if let str = NewsicPreferredPlayer(rawValue: value) {
                
                let buttonSpotify = YBButton(frame: CGRect.zero, icon: UIImage(named: "SpotifyIconHighlighted"), text: NewsicPreferredPlayer.spotify.description())
                let actionSpotify = { () -> Void in
                    self.settings?.preferredPlayer = NewsicPreferredPlayer.spotify
                    cell.itemValue.text = buttonSpotify.textLabel.text
                }
                buttonSpotify.action = actionSpotify
                
                let buttonYoutube = YBButton(frame: CGRect.zero, icon: UIImage(named: "YoutubeIconHighlighted"), text: NewsicPreferredPlayer.youtube.description())
                let actionYoutube = { () -> Void in
                    self.settings?.preferredPlayer = NewsicPreferredPlayer.youtube
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
        let buttonLogout = YBButton(frame: CGRect.zero, icon: nil, text: "Yes")
        let actionLogout = { () -> Void in
            self.logoutUser()
            cell.itemValue.text = buttonLogout.textLabel.text
        }
        buttonLogout.action = actionLogout
        cell.configureCell(title: title, value: "", icon: nil, options: [buttonLogout], centerText: true, alertText: "Are you sure?")
        
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

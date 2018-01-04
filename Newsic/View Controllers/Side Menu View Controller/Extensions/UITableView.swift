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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        self.present(cell.alertController!, animated: true, completion: nil)
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
            if let value = settings?.preferredPlayer?.rawValue {
                if let str = NewsicPreferredPlayer(rawValue: value) {
                    
                    let actionSpotify = UIAlertAction(title: NewsicPreferredPlayer.spotify.description(), style: UIAlertActionStyle.default, handler: { (action) in
                        self.settings?.preferredPlayer = NewsicPreferredPlayer.spotify
                        cell.itemValue.text = action.title
                    })
                    
                    let actionYoutube = UIAlertAction(title: NewsicPreferredPlayer.youtube.description(), style: UIAlertActionStyle.default, handler: { (action) in
                        self.settings?.preferredPlayer = NewsicPreferredPlayer.youtube
                        cell.itemValue.text = action.title
                    })
                    
                    cell.configureCell(title: title, value: str.description(), options: [actionSpotify, actionYoutube], acessoryType: UITableViewCellAccessoryType.disclosureIndicator, enableCell: enablePlayerSwitch!)
                    
                }
            }
        case NewsicSettingsLabel.spotifyQuality.rawValue:
            if let bitrate = settings?.spotifySettings?.bitrate {
                let actionHigh = UIAlertAction(title: "High", style: UIAlertActionStyle.default, handler: { (action) in
                    self.settings?.spotifySettings?.bitrate = .high
                    cell.itemValue.text = action.title
                })
                
                let actionNormal = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default, handler: { (action) in
                    self.settings?.spotifySettings?.bitrate = .normal
                    cell.itemValue.text = action.title
                })
                
                let actionLow = UIAlertAction(title: "Low", style: UIAlertActionStyle.default, handler: { (action) in
                    self.settings?.spotifySettings?.bitrate = .low
                    cell.itemValue.text = action.title
                })
                
                cell.configureCell(title: title, value: bitrate.description(), options: [actionHigh, actionNormal, actionLow], acessoryType: UITableViewCellAccessoryType.disclosureIndicator)
            }
        case NewsicSettingsLabel.useMobileData.rawValue:
            if let useMobileData = settings?.useMobileData {
                
                let actionOn = UIAlertAction(title: (true).toString(), style: UIAlertActionStyle.default, handler: { (action) in
                    self.settings?.useMobileData = true
                    cell.itemValue.text = action.title
                })
                
                let actionOff = UIAlertAction(title: (false).toString(), style: UIAlertActionStyle.default, handler: { (action) in
                    self.settings?.useMobileData = false
                    cell.itemValue.text = action.title
                })
                
                cell.configureCell(title: title, value: useMobileData.toString(), options: [actionOn, actionOff], acessoryType: UITableViewCellAccessoryType.disclosureIndicator)
            }
        case NewsicSettingsLabel.logout.rawValue:
            let actionLogout = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.logoutUser()
            })
            cell.configureCell(title: title, value: "", options: [actionLogout], centerText: true, alertText: "Are you sure?")
        default:
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
}

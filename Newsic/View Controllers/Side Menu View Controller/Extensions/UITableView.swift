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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SettingsCellHeader(frame: CGRect(x: settingsTableView.frame.origin.x, y: settingsTableView.frame.origin.y, width: settingsTableView.frame.width, height: 80))
        switch section {
        case Section.playerSettings.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.playerSettings.rawValue
        case Section.connectionSettings.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.connectionSettings.rawValue
        case Section.actionSettings.rawValue:
            header.headerLabel.text = NewsicSettingsTitle.actionSettings.rawValue
        default:
            header.headerLabel.text = ""
        }
        return header;
    }
    
}

extension SideMenuViewController2 : UITableViewDataSource {
    
    enum Section: Int {
        case playerSettings
        case connectionSettings
        case actionSettings
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.actionSettings.rawValue + 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsValues[section].count
//        switch section {
//        case Section.playerSettings.rawValue:
//            return 1
//        case Section.connectionSettings.rawValue:
//            return 1
//        case Section.actionSettings.rawValue:
//            return 1
//        default:
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseIdentifier, for: indexPath) as? SettingsCell else { fatalError("Unexpected Table View Cell") }
        
        let title = settingsValues[indexPath.section][0]
        switch indexPath.section {
        case Section.playerSettings.rawValue:
            if let value = settings?.preferredPlayer?.rawValue {
                if let str = NewsicPreferredPlayer(rawValue: value) {
                    
                    
                    let actionSpotify = UIAlertAction(title: NewsicPreferredPlayer.spotify.description(), style: UIAlertActionStyle.default, handler: { (action) in
                        self.settings?.preferredPlayer = NewsicPreferredPlayer.spotify
                    })
                    
                    let actionYoutube = UIAlertAction(title: NewsicPreferredPlayer.youtube.description(), style: UIAlertActionStyle.default, handler: { (action) in
                        self.settings?.preferredPlayer = NewsicPreferredPlayer.youtube
                    })
                    
                    cell.configureCell(title: title, value: str.description(), options: [actionSpotify, actionYoutube], acessoryType: UITableViewCellAccessoryType.disclosureIndicator)
                    
                }
            }
        case Section.connectionSettings.rawValue:
            if let useMobileData = settings?.useMobileData?.toString() {
                cell.configureCell(title: title, value: useMobileData)
            }
        case Section.actionSettings.rawValue:
            cell.configureCell(title: title, value: "")
        default:
            return UITableViewCell()
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    
}

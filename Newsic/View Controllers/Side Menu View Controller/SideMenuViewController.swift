//
//  SideMenuViewController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog

class SideMenuViewController: NusicDefaultViewController {
    
    
    //Local variables
    var navbar: UINavigationBar?
    var profileImage: UIImage?
    var username: String?
    var profileImageURL: URL?
    var useMobileData: Bool?
    var preferredPlayer: NusicPreferredPlayer?
    var enablePlayerSwitch: Bool?
    var nusicUser: NusicUser?
    var settings: NusicUserSettings?
    var settingsValues:[[String]]!
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        nusicUser?.settingValues = settings!
        nusicUser?.saveSettings(saveSettingsHandler: { (didSave, error) in
            if let error = error {
                error.presentPopup(for: self)
            }
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        setupSettingsArray()
        setupTableView()
//        setupNavigationBar()
        
        settings = nusicUser?.settingValues
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        setupNavigationBar()
    }
   
    @objc func dismissMenu() {
        let vc = self.parent as! NusicPageViewController
        vc.scrollToViewController(index: 1)
    }
    
    fileprivate func setupSettingsArray() {
        settingsValues = [[NusicSettingsLabel.preferredPlayer.rawValue]]
        if let preferredPlayer = preferredPlayer, preferredPlayer == .spotify {
            settingsValues.append([NusicSettingsLabel.spotifyQuality.rawValue])
        }
        settingsValues.append([NusicSettingsLabel.useMobileData.rawValue])
        settingsValues.append([NusicSettingsLabel.logout.rawValue])
        
        
    }
    
    fileprivate func setupNavigationBar() {
        
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        if let navbar = navbar {
            navbar.barStyle = .default
            navbar.translatesAutoresizingMaskIntoConstraints = false
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "MoodIcon"), for: .normal)
            button.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: button);
            let barButton2 = UIBarButtonItem(image: UIImage(named: "MoodIcon"), style: .plain, target: self, action: #selector(dismissMenu));
            self.navigationItem.rightBarButtonItem = barButton
            
            let navItem = self.navigationItem
            navbar.items = [navItem]
            if !self.view.subviews.contains(navbar) {
                self.view.addSubview(navbar)
            }
            NSLayoutConstraint.activate([
                navbar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
                navbar.heightAnchor.constraint(equalToConstant: 44),
                navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
                ])
            
            self.view.layoutIfNeeded()
        }
    }

    func logoutUser() {
        
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
        
        if SPTAudioStreamingController.sharedInstance().initialized {
            SPTAudioStreamingController.sharedInstance().logout()
        }
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyLogin") as! SpotifyLoginViewController
        
        self.present(viewController, animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "resetLogin"), object: nil)
        });
        
    }
}



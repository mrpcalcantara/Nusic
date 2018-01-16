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
   
    func setupSettingsArray() {
        settingsValues = [[NusicSettingsLabel.preferredPlayer.rawValue]]
        if let preferredPlayer = preferredPlayer, preferredPlayer == .spotify {
            settingsValues.append([NusicSettingsLabel.spotifyQuality.rawValue])
        }
        settingsValues.append([NusicSettingsLabel.useMobileData.rawValue])
        settingsValues.append([NusicSettingsLabel.logout.rawValue])
        
        
    }
    
    func setupNavigationBar() {
        
        if let navbar = navbar {
            if self.view.subviews.contains(navbar) {
                navbar.removeFromSuperview()
            }
        }
        
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        if let navbar = navbar {
            navbar.barStyle = .default
            let button = UIButton(type: .system)
            button.setImage(UIImage(named: "MoodIcon"), for: .normal)
            button.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: button);
            let barButton2 = UIBarButtonItem(image: UIImage(named: "MoodIcon"), style: .plain, target: self, action: #selector(dismissMenu));
            self.navigationItem.rightBarButtonItem = barButton
            
            let navItem = self.navigationItem
            navbar.items = [navItem]
            self.view.addSubview(navbar)
        }
    }
    
    @objc func dismissMenu() {
        let vc = self.parent as! NusicPageViewController
        vc.scrollToViewController(index: 1)
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



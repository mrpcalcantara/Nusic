//
//  SideMenuViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog

class SideMenuViewController: NewsicDefaultViewController {
    
    
    //Local variables
    var navbar: UINavigationBar?
    var profileImage: UIImage?
    var username: String?
    var profileImageURL: URL?
    var useMobileData: Bool?
    var preferredPlayer: NewsicPreferredPlayer?
    var enablePlayerSwitch: Bool?
    var newsicUser: NewsicUser?
    var settings: NewsicUserSettings?
    var settingsValues:[[String]]!
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        newsicUser?.settingValues = settings!
        newsicUser?.saveSettings(saveSettingsHandler: { (didSave, error) in
            if let error = error {
                error.presentPopup(for: self)
            }
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        setupSettingsArray()
        setupTableView()
        setupNavigationBar()
        
        settings = newsicUser?.settingValues
        
    }
    
    func setupSettingsArray() {
        settingsValues = [[NewsicSettingsLabel.preferredPlayer.rawValue]]
        settingsValues.append([NewsicSettingsLabel.spotifyQuality.rawValue])
        settingsValues.append([NewsicSettingsLabel.useMobileData.rawValue])
        settingsValues.append([NewsicSettingsLabel.logout.rawValue])
        
        
    }
    
    func setupNavigationBar() {
        
        navbar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44));
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
        let vc = self.parent as! NewsicPageViewController
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



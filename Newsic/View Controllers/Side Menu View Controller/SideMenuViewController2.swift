//
//  SideMenuViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import PopupDialog

class SideMenuViewController2: NewsicDefaultViewController {
    
    
    //Local variables
    var navbar: UINavigationBar?
    var profileImage: UIImage?
    var username: String?
    var profileImageURL: URL?
    var useMobileData: Bool?
    var preferredPlayer: NewsicPreferredPlayer?
    var enablePlayerSwitch: Bool?
    var settings: NewsicUserSettings?
    var settingsValues:[[String]]!
    
    @IBOutlet weak var settingsTableView: UITableView!
    //    
//    @IBAction func logoutClicked(_ sender: Any) {
//        logoutUser()
//        
//        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyLogin") as! SpotifyLoginViewController
//        
//        self.present(viewController, animated: true, completion: nil);
//        //self.navigationController?.popViewController(animated: true);
//    }
//    
//    func logoutUser() {
//        UserDefaults.standard.removeObject(forKey: "SpotifySession");
//        UserDefaults.standard.synchronize();
////        NotificationCenter.default.post(name: Notification.Name(rawValue: "resetLogin"), object: nil)
//        if SPTAudioStreamingController.sharedInstance().initialized {
//           SPTAudioStreamingController.sharedInstance().logout()
//        }
//    }
//    
//    @IBAction func preferredPlayerAction(_ sender: UISwitch) {
//        
//        let parent = self.parent as! NewsicPageViewController
//        let songPicker = parent.songPickerVC as! SongPickerViewController
//        
//        if sender.isOn {
//            preferredPlayerLabel.text = "Preferred Player: YouTube"
//            preferredPlayer = NewsicPreferredPlayer.youtube
//        } else {
//            preferredPlayerLabel.text = "Preferred Player: Spotify"
//            preferredPlayer = NewsicPreferredPlayer.spotify
//        }
//        
//        if !enablePlayerSwitch! {
//            let popup = PopupDialog(title: "Sorry!", message: "It appears you're not a Spotify Premium user. As such, you can only use the YouTube player.")
//            popup.addButton(DefaultButton(title: "Got It!", action: nil))
//            self.present(popup, animated: true, completion: nil)
//            sender.isOn = true
//        } else {
//            songPicker.newsicUser.settingValues.preferredPlayer = preferredPlayer
//            songPicker.newsicUser.saveSettings(saveSettingsHandler: { (isSaved, error) in
//                if let error = error {
//                    error.presentPopup(for: self)
//                }
//            })
//        }
//        
//    }
//    
//    @IBAction func connectionSwitchChanged(_ sender: UISwitch) {
//        let parent = self.parent as! NewsicPageViewController
//        let songPicker = parent.songPickerVC as! SongPickerViewController
//        
//        if sender.isOn {
//            connectionLabel.text = "Use Mobile Data: Yes"
//        } else {
//            connectionLabel.text = "Use Mobile Data: No"
//        }
//        
//        useMobileData = sender.isOn
//        
//        songPicker.newsicUser.settingValues.useMobileData = useMobileData
//        songPicker.newsicUser.saveSettings(saveSettingsHandler: { (isSaved, error) in
//            if let error = error {
//                error.presentPopup(for: self)
//            }
//        })
//    }
//    
//    @IBAction func aboutClicked(_ sender: Any) {
//        
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        preferredPlayerSwitch.isUserInteractionEnabled = enablePlayerSwitch!
        
//        setupSettingsView()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        setupSettingsArray()
        setupTableView()
        setupNavigationBar()
        
    }
//
//    func setupView() {
//        if let profileImageURL = profileImageURL {
//            profileImageView.downloadedFrom(url: profileImageURL, contentMode: .scaleAspectFit, roundImage: true);
//        } else {
//            let iconImage = UIImage(named: "AppIcon")
//            profileImageView.image = iconImage
//        }
//
////        profileImageView.roundImage();
////        if let profileImage = profileImage {
////            profileImageView.image = profileImage;
////        }
////
//        if let username = username {
//            usernameLabel.text = username
//        }
//
////        setupProfileView();
////        setupButtonsView();
//    }
    
    func setupSettingsArray() {
        settingsValues = [[NewsicSettingsLabel.useMobileData.rawValue]]
        settingsValues.append([NewsicSettingsLabel.preferredPlayer.rawValue])
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
            //        navbar.layer.zPosition = 1
            //        self.view.insertSubview(navbar, at: 0)
            self.view.addSubview(navbar)
            
            //        navigationItem.hidesBackButton = true
        }
    }
//
//    func setupProfileView() {
//        profileView.backgroundColor = UIColor.clear
//        usernameLabel.textColor = UIColor.white
//        drawProfileViewPath()
//        //profileView.addBlurEffect(style: .extraLight, alpha: 0.25);
//    }
//
//    func setupButtonsView() {
//        buttonsView.backgroundColor = UIColor.clear
//        //buttonsView.addBlurEffect(style: .dark, alpha: 0.8)
//        logoutButton.tintColor = UIColor.green
//    }
//
//    func setupSettingsView() {
//        if preferredPlayer == NewsicPreferredPlayer.spotify {
//            preferredPlayerLabel.text = "Preferred Player: Spotify"
//            preferredPlayerSwitch.isOn = false
//        } else {
//            preferredPlayerLabel.text = "Preferred Player: YouTube"
//            preferredPlayerSwitch.isOn = true
//        }
//
//        if let useMobileData = useMobileData {
//            if useMobileData {
//                connectionLabel.text = "Use Mobile Data: Yes"
//            } else {
//                connectionLabel.text = "Use Mobile Data: No"
//            }
//
//            connectionSwitch.isOn = useMobileData;
//        }
//
//    }
//
//    func drawProfileViewPath() {
//        let layer = CAShapeLayer();
//        let yOrigin = profileView.bounds.origin.y + 8
//        let xOrigin = profileView.bounds.origin.x
//        let width = profileView.bounds.width
//        let height = profileView.bounds.height
//        layer.strokeColor = UIColor.white.cgColor
//        layer.fillColor = UIColor.clear.cgColor
//        layer.lineWidth = 5
//
//
//
//        let path = UIBezierPath()
////        path.move(to: CGPoint(x: xOrigin - 8, y: yOrigin))
////        path.addQuadCurve(to: CGPoint(x: width + 8, y: yOrigin), controlPoint: CGPoint(x: width/2, y: -10))
////        path.addLine(to: CGPoint(x: width + 8, y: height + 8))
////        path.addLine(to: CGPoint(x: xOrigin - 8, y: height + 8))
////        path.close()
//
//        path.move(to: CGPoint(x: xOrigin - 8, y: height))
//        path.addQuadCurve(to: CGPoint(x: width + 8, y: height), controlPoint: CGPoint(x: width/2, y: height+10))
//        path.addLine(to: CGPoint(x: width + 8, y: yOrigin + 8))
//        path.addLine(to: CGPoint(x: xOrigin - 8, y: yOrigin + 8))
//        path.close()
//        layer.path = path.cgPath
//        layer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
//        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 2])
//        //layer.backgroundFilters = [filter]
//        profileView.layer.insertSublayer(layer, at: 0)
//
//        let animation = CABasicAnimation(keyPath: "strokeEnd");
//
//        animation.fromValue = 0.5
//        animation.toValue = 1.0
//        animation.duration = 2
//
//        layer.add(animation, forKey: "drawLineAnimation")
//    }
    
    @objc func dismissMenu() {
//        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true);
        //let root = self.navigationController?.topViewController
//        let navcontr = self.navigationController
        let vc = self.parent as! NewsicPageViewController
        vc.scrollToViewController(index: 1)
        
    }
    
}



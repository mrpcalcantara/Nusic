//
//  SideMenuViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    //Local variables
    var profileImage: UIImage?
    var username: String?
    
    @IBAction func logoutClicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyLogin") as! SpotifyLoginViewController
        self.present(viewController, animated: true, completion: nil);
        //self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func aboutClicked(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupView();
        setupNavigatonBar()
    }
    
    func setupView() {
        profileImageView.roundImage();
        if let profileImage = profileImage {
            profileImageView.image = profileImage;
        }
        
        if let username = username {
            usernameLabel.text = username
        }
        
        logoutButton.titleLabel?.text = "Logout from Spotify"
        aboutButton.titleLabel?.text = "About this App"
    }
    
    func setupNavigatonBar() {
        navigationItem.hidesBackButton = true
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "MoodIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1;
    }
    
    @objc func dismissMenu() {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
}



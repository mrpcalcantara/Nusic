//
//  SideMenuViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SideMenuViewController: NewsicDefaultViewController {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    
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
        
        setupProfileView();
        setupButtonsView();
    }
    
    func setupNavigatonBar() {
        navigationItem.hidesBackButton = true
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "MoodIcon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        btn1.imageView?.tintColor = UIColor.white
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1;
    }
    
    func setupProfileView() {
        profileView.backgroundColor = UIColor.clear
        usernameLabel.textColor = UIColor.white
        //profileView.addBlurEffect(style: .extraLight, alpha: 0.25);
    }
    
    func setupButtonsView() {
        buttonsView.backgroundColor = UIColor.clear
        //buttonsView.addBlurEffect(style: .dark, alpha: 0.8)
        drawButtonsViewPath();
    }
    
    func drawButtonsViewPath() {
        let layer = CAShapeLayer();
        let yOrigin = buttonsView.bounds.origin.y + 8
        let xOrigin = buttonsView.bounds.origin.x
        let width = buttonsView.bounds.width
        let height = buttonsView.bounds.height
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 5
        
        
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xOrigin - 8, y: yOrigin))
        path.addQuadCurve(to: CGPoint(x: width + 8, y: yOrigin), controlPoint: CGPoint(x: width/2, y: -10))
        path.addLine(to: CGPoint(x: width + 8, y: height + 8))
        path.addLine(to: CGPoint(x: xOrigin - 8, y: height + 8))
        path.close()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 2])
        //layer.backgroundFilters = [filter]
        buttonsView.layer.insertSublayer(layer, at: 0)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd");
        
        animation.fromValue = 0.5
        animation.toValue = 1.0
        animation.duration = 2
        
        layer.add(animation, forKey: "drawLineAnimation")
    }
    
    @objc func dismissMenu() {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
}



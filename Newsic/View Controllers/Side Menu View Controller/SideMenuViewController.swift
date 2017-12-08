//
//  SideMenuViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 25/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SideMenuViewController: NewsicDefaultViewController {
    
    @IBOutlet weak var menuScrollView: UIScrollView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    
    //Local variables
    var profileImage: UIImage?
    var username: String?
    var profileImageURL: URL?
    var navbar: UINavigationBar?
    
    @IBAction func logoutClicked(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyLogin") as! SpotifyLoginViewController
        self.present(viewController, animated: true, completion: nil);
        //self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func aboutClicked(_ sender: Any) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        setupView();
        setupNavigationBar()
        
    }
    
    func setupView() {
        if let profileImageURL = profileImageURL {
            profileImageView.downloadedFrom(url: profileImageURL, contentMode: .scaleAspectFit, roundImage: true);
        } else {
            profileImageView.backgroundColor = UIColor.black
        }
        
//        profileImageView.roundImage();
//        if let profileImage = profileImage {
//            profileImageView.image = profileImage;
//        }
//
        if let username = username {
            usernameLabel.text = username
        }
        
        setupProfileView();
        setupButtonsView();
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
    
    func setupProfileView() {
        profileView.backgroundColor = UIColor.clear
        usernameLabel.textColor = UIColor.white
        drawProfileViewPath()
        //profileView.addBlurEffect(style: .extraLight, alpha: 0.25);
    }
    
    func setupButtonsView() {
        buttonsView.backgroundColor = UIColor.clear
        //buttonsView.addBlurEffect(style: .dark, alpha: 0.8)
        logoutButton.tintColor = UIColor.green
    }
    
    func drawProfileViewPath() {
        let layer = CAShapeLayer();
        let yOrigin = profileView.bounds.origin.y + 8
        let xOrigin = profileView.bounds.origin.x
        let width = profileView.bounds.width
        let height = profileView.bounds.height
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 5
        
        
        
        let path = UIBezierPath()
//        path.move(to: CGPoint(x: xOrigin - 8, y: yOrigin))
//        path.addQuadCurve(to: CGPoint(x: width + 8, y: yOrigin), controlPoint: CGPoint(x: width/2, y: -10))
//        path.addLine(to: CGPoint(x: width + 8, y: height + 8))
//        path.addLine(to: CGPoint(x: xOrigin - 8, y: height + 8))
//        path.close()
        
        path.move(to: CGPoint(x: xOrigin - 8, y: height))
        path.addQuadCurve(to: CGPoint(x: width + 8, y: height), controlPoint: CGPoint(x: width/2, y: height+10))
        path.addLine(to: CGPoint(x: width + 8, y: yOrigin + 8))
        path.addLine(to: CGPoint(x: xOrigin - 8, y: yOrigin + 8))
        path.close()
        layer.path = path.cgPath
        layer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: [kCIInputRadiusKey: 2])
        //layer.backgroundFilters = [filter]
        profileView.layer.insertSublayer(layer, at: 0)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd");
        
        animation.fromValue = 0.5
        animation.toValue = 1.0
        animation.duration = 2
        
        layer.add(animation, forKey: "drawLineAnimation")
    }
    
    @objc func dismissMenu() {
//        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true);
        //let root = self.navigationController?.topViewController
        let vc = self.parent as! NewsicPageViewController
        vc.scrollToViewController(index: 1)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let view = touch?.view
        print(touch?.view.debugDescription)
    }
    
}



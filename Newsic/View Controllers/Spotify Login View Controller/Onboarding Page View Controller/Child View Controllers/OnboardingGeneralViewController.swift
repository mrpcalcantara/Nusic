//
//  OnboardingGeneralViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 19/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class OnboardingGeneralViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    
    var image: UIImage?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        image = nil
        DispatchQueue.main.async {
            self.imageView.image = nil
        }
    }
    
    fileprivate func setupView() {
        stepLabel.textColor = NusicDefaults.whiteColor
        let font = UIDevice.current.userInterfaceIdiom == .phone ? NusicDefaults.font?.withSize(14) : NusicDefaults.font?.withSize(22)
        stepLabel.font = font
        stepLabel.lineBreakMode = .byWordWrapping
        stepLabel.numberOfLines = 0
        
        
        imageView.contentMode = .scaleAspectFit
    }
    
    fileprivate func setData() {
        DispatchQueue.main.async {
            self.stepLabel.text = self.text
            self.stepLabel.sizeToFit()
            self.imageView.image = self.image
            self.view.backgroundColor = NusicDefaults.clearColor
            self.view.layoutIfNeeded()
        }
    }
    
    final func configure(image: UIImage?, text: String?) {
        guard let image = image, let text = text else { return }
        self.image = image
        self.text = text
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

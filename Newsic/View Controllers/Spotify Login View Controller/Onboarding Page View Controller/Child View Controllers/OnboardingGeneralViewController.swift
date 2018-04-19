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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupView() {
        view.backgroundColor = NusicDefaults.clearColor
        
        stepLabel.textColor = NusicDefaults.whiteColor
        stepLabel.font = NusicDefaults.font
        stepLabel.lineBreakMode = .byWordWrapping
        stepLabel.numberOfLines = 0
        
        imageView.contentMode = .scaleAspectFit
        
        stepLabel.text = text
        imageView.image = image
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

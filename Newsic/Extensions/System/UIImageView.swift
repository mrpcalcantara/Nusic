//
//  UIImageView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension UIImageView {
    
    final func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, roundImage: Bool? = false) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                guard roundImage! else { return }
                self.roundImage();
                
            }
            }.resume()
    }
    
    final func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, roundImage: Bool? = false) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    final func roundImage(border: Bool? = false) {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true;
        guard border! else { return }
        addRoundBorder()
    }
    
    private func addRoundBorder(borderColor: UIColor? = UIColor.white.withAlphaComponent(0.8), borderWidth: CGFloat? = 8) {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.frame.height/2)
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = borderColor?.cgColor
        border.lineWidth = borderWidth!
        
        self.layer.addSublayer(border)
    }
}

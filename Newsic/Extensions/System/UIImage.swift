//
//  UIImage.swift
//  Nusic
//
//  Created by Miguel Alcantara on 11/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension UIImage {
    
    func downloadImage(from url: URL, downloadImageHandler: @escaping(UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { downloadImageHandler(nil); return; }
            
            downloadImageHandler(image);
        }.resume()
    }
    
    
}

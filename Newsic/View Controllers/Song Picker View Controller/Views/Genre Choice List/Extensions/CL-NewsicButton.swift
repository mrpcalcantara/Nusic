//
//  CL-NusicButton.swift
//  Nusic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension ChoiceListView {
    
    func setupButton() {
        fetchSongsButton.allowBlur = true
        fetchSongsButton.tintColor = NusicDefaults.foregroundThemeColor
        fetchSongsButton.setTitle("Get Songs!", for: .normal)
        fetchSongsButton.addTarget(self, action: #selector(triggerButton), for: .touchUpInside)
    }
    
    @objc func triggerButton() {
        delegate?.getSongs()
    }
    
}
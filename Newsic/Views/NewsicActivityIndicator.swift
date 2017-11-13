//
//  NewsicActivityIndicator.swift
//  Newsic
//
//  Created by Miguel Alcantara on 12/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

class NewsicActivityIndicator: UIView {
    
    public class var sharedInstance: NewsicActivityIndicator {
        struct Singleton {
            static let instance = NewsicActivityIndicator(frame: CGRect.zero)
        }
        return Singleton.instance
    }
    
    private var blurEffectStyle: UIBlurEffectStyle = .prominent
    private var blurEffect: UIBlurEffect!
    private var blurView: UIVisualEffectView!
    private var vibrancyView: UIVisualEffectView!
    private var titleLabel: UILabel!
    private var activityIndicatorView: UIActivityIndicatorView!
    let frameSize = CGSize(width: 200.0, height: 200.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        blurEffect = UIBlurEffect(style: blurEffectStyle)
        blurView = UIVisualEffectView()
        blurView.frame = frame;
        addSubview(blurView)
        
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        addSubview(vibrancyView)
        
        activityIndicatorView = UIActivityIndicatorView();
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.color = UIColor.brown;
        
        addSubview(activityIndicatorView)
        
        
        let titleScale: CGFloat = 0.85
        titleLabel = UILabel();
        titleLabel.frame.size = CGSize(width: frameSize.width * titleScale, height: frameSize.height * titleScale)
        //titleLabel.font = currentTitleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor.white
        
        titleLabel.text = "TEST";
        //titleLabel.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: 8)
        
        blurView.contentView.addSubview(titleLabel)
        
        //blurView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true;
        //blurView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show(_ title: String, animated: Bool = true) -> NewsicActivityIndicator {
        activityIndicatorView.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true;
        activityIndicatorView.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true;
        titleLabel.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true;
        titleLabel.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 8).isActive = true
        let spinner = NewsicActivityIndicator.sharedInstance
        
        if spinner.superview == nil {
            //show the spinner
            spinner.blurView.contentView.alpha = 0
            
            UIApplication.shared.keyWindow?.addSubview(spinner)
            
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                
                spinner.blurView.contentView.alpha = 1
                spinner.blurView.effect = spinner.blurEffect
                
            }, completion: nil)
            spinner.activityIndicatorView.startAnimating();
            spinner.activityIndicatorView.alpha = 1
        }
        
        return spinner
    }
    
    func hide(_ completion: (() -> Void)? = nil) {
        
        let spinner = NewsicActivityIndicator.sharedInstance
        
        NotificationCenter.default.removeObserver(spinner)
        
        DispatchQueue.main.async(execute: {
            
            if spinner.superview == nil {
                return
            }
            
            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                
                spinner.blurView.contentView.alpha = 0
                spinner.blurView.effect = nil
                
            }, completion: {_ in
                spinner.blurView.contentView.alpha = 1
                spinner.removeFromSuperview()
                spinner.titleLabel.text = nil
                
                completion?()
            })
            
            spinner.activityIndicatorView.stopAnimating()
        })
    }
    /*
    @discardableResult
    func customActivityIndicatory(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor.init(netHex: 0xFFFFFF)
        mainContainer.alpha = 0.5
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = UIColor.init(netHex: 0x444444)
        viewBackgroundLoading.alpha = 0.5
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
    */
    
}

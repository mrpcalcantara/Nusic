//
//  YoutubePlayerViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import youtube_ios_player_helper

class YoutubePlayerViewController: UIViewController, YTPlayerViewDelegate {
    
    @IBOutlet weak var videoPlayer: YTPlayerView!
    
    var videoID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var playerVars: [String: AnyObject]?;
        playerVars?["playsinline"] = 1 as AnyObject
        playerVars?["modestbranding"] = 1 as AnyObject
        //videoPlayer.load(withVideoId: videoID)
        videoPlayer.load(withVideoId: videoID, playerVars: playerVars)
    }
    
    
    
}

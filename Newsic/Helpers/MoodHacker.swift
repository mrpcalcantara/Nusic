//
//  MoodHacker.swift
//  Nusic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct MoodHacker {
    
    static let apiKey = "xCFOWcU1Yjmshq0AL6LXx70Ys5tNp1RHkXljsnL5FqNar8DX0A"
    static let endpointUrl = "https://shl-mp.p.mashape.com/webresources/jammin/emotionV2";
    
    var emotions: [Emotion]? = []
    
    init(emotions: [Emotion]? = nil) {
        self.emotions = emotions
    }
    /*
    func getMood(for userText:String?, completionHandler: @escaping (NusicMood?, Bool?) -> ()) {
    
        guard let userText = userText, userText != "Tell me how are you feeling.." && userText != "" else {
            var nusicMood = NusicMood();
            nusicMood.emotions = [Emotion(basicGroup: .unknown, detailedEmotions: [], rating: 0)]
            completionHandler(nusicMood, false);
            return;
        }
        
        let url = URL(string: MoodHacker.endpointUrl);
        var request = URLRequest(url: url!);
        request.httpMethod = "POST";
        request.allHTTPHeaderFields = [
            "X-Mashape-Key":MoodHacker.apiKey,
            "Accept":"application/json",
            "Content-Type":"application/x-www-form-urlencoded"]
        let lang = "lang=en"
        let text = "text=\(userText)"
        let body = "\(lang)&\(text)";
        request.httpBody = body.data(using: .utf8)
        //print(String.init(data: request.httpBody!, encoding: .utf8))
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            if let data = data, httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                do {
                    let dataJson = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject];
                    let ambiguous = dataJson["ambiguous"] as! String
                    if ambiguous == "yes" {
                        completionHandler(nil, true)
                    } else {
                        let emotionGroups = dataJson["groups"] as! [[String: AnyObject]]
                        var result = NusicMood()
                        for emotion in emotionGroups {
                            
                            var listEmotions:[String] = []
                            let detailedEmotions = emotion["emotions"] as! [String];
                            for emotionDetail in detailedEmotions {
                                listEmotions.append(emotionDetail);
                            }
                            
                            let group = emotion["name"] as? String;
                            
                            
                            if let group = group, listEmotions.count > 0 {
                                var emotion = Emotion();
                                emotion.detailedEmotions = listEmotions
                                emotion.basicGroup = group;
                                emotion.rating = Double(listEmotions.count/100);
                                if group != "joy" {
                                    emotion.rating = emotion.rating * -1
                                }
                                result.emotions.append(emotion)
                            }
                            
                        }
                        
                        completionHandler(result, false);
                    }
                    
                    
                    
                } catch {
                    
                }
                
            } else {
                completionHandler(nil, false)
            }
        }.resume();
        //let headers = request
    }
    
    
    */
}

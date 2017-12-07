//
//  URLSession.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension URLSession {
    
    func executeCall(with request: URLRequest, retryNumber: Int? = 3, retryAfter: Int? = 5, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?, Bool) -> ()) {
        var retryNumberLeft = retryNumber!
        
        let session = URLSession.shared;
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(data, nil, error, false);
            } else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (200...299).contains(statusCode) {
                    if let url = request.url {
                        print("Call OK for URL: \(url.absoluteString)")
                    }
                    completionHandler(data, httpResponse, error, true)
                }
                else {
                    if var retryAfter = retryAfter {
                        if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
                            retryAfter = Int(httpResponse.allHeaderFields["retry-after"] as! String)!;
                            retryNumberLeft += 1;
                        }
                        if retryNumberLeft > 0 {
                            let timeToWait = DispatchTime.now()+Double(retryAfter)
                            if let url = request.url {
                                print("Error: \(statusCode) - Retrying call for URL: \(url.absoluteString)")
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: timeToWait, execute: {
                                self.executeCall(with: request, retryNumber: retryNumberLeft-1, retryAfter: retryAfter, completionHandler: completionHandler)
                            })
                        } else {
                            completionHandler(data, httpResponse, error, false);
                        }
                    }
                }
            }
        }.resume()
    }
}

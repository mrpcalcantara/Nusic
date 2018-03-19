//
//  URLSession.swift
//  Nusic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension URLSession {
    
    final func executeCall(with request: URLRequest, retryNumber: Int? = 3, retryAfter: Int? = 10, completionHandler: @escaping (Data?, HTTPURLResponse?, Error?, Bool) -> ()) {
        var retryNumberLeft = retryNumber!
        
        let session = URLSession.shared;
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else { completionHandler(data, nil, error, false); return }
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (200...299).contains(statusCode) {
                completionHandler(data, httpResponse, error, true)
            }
            else {
                guard var retryAfter = retryAfter else { return }
                guard retryNumberLeft > 0 else { completionHandler(data, httpResponse, error, false); return }
                switch statusCode {
                case HTTPErrorCodes.tooManyRequests.rawValue:
                    retryAfter = Int(httpResponse.allHeaderFields["retry-after"] as! String)!;
                    retryNumberLeft += 1;
                case HTTPErrorCodes.unauthorized.rawValue:
                    completionHandler(data, httpResponse, error, false);
                default:
                    let timeToWait = DispatchTime.now()+Double(retryAfter)
                    DispatchQueue.main.asyncAfter(deadline: timeToWait, execute: {
                        self.executeCall(with: request, retryNumber: retryNumberLeft-1, retryAfter: retryAfter, completionHandler: completionHandler)
                    })
                }
            }
        }.resume()
    }

}

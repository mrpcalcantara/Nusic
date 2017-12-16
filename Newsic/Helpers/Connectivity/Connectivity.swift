//
//  Connectivity.swift
//  Newsic
//
//  Created by Miguel Alcantara on 08/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Connectivity {
    
    class func isConnectedToNetwork() -> ConnectivityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notConnected
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notConnected
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notConnected
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .connectedCellular
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .connectedWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .connectedWiFi
        }
        else {
            return .notConnected
        }
        
        
    }
    
    class func isConnectedToNetworkTEST() -> ConnectivityStatus {
        return .connectedCellular
    }
    
}


//
//  ErrorCodes.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum ErrorCodes: Int {
    case okResponse = 200
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case tooManyRequests = 429
    case internalError = 500
    case badGateway = 502
    case serviceUnavailable = 503
}

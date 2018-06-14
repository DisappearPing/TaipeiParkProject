//
//  APIError.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/11.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

enum APIError: Error {
    case responseError
    case JSONConvertFail
    case networkError
    case operationCanceled
    case responseDataNil
    case unknown
}

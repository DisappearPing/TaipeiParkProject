//
//  GetListMiddleResult.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/11.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct GetListMiddleResult: Codable {
    let count : Int?
    let limit : Int?
    let offset : Int?
    let results : [Park]?
    let sort : String?
}

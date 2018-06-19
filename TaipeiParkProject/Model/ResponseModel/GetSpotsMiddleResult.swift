//
//  GetSpotsMiddleResult.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct GetSpotsMiddleResult: Codable {
    let count : Int?
    let limit : Int?
    let offset : Int?
    let results : [Spot]?
    let sort : String?
}

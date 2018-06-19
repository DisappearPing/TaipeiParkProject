//
//  GetSpotsRequest.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct GetSpotsRequest: DictionaryEncodable {
    var q: String
    let rid = "bf073841-c734-49bf-a97f-3757a6013812"
    let scope = "resourceAquire"
}

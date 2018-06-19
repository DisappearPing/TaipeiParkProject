//
//  GetListRequest.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/12.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct GetListRequest: DictionaryEncodable {
    let id = "a132516d-d2f3-4e23-866e-27e616b3855a"
    let rid = "8f6fcb24-290b-461d-9d34-72ed1b3f51f0"
    let limit = 15
    let scope = "resourceAquire"
    var offset: Int
}

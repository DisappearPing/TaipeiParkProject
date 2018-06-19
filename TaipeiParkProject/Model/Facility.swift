//
//  Facility.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct Facility: Codable {
    let facilityName: String?
    
    enum CodingKeys: String, CodingKey {
        case facilityName = "facility_name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        facilityName = try values.decodeIfPresent(String.self, forKey: .facilityName)
    }
}

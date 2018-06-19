//
//  Spot.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

struct Spot: Codable {
    let parkName: String?
    let spotName: String?
    let openTime: String?
    let introduction : String?
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case parkName = "ParkName"
        case spotName = "Name"
        case openTime = "OpenTime"
        case introduction = "Introduction"
        case image = "Image"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        parkName = try values.decodeIfPresent(String.self, forKey: .parkName)
        spotName = try values.decodeIfPresent(String.self, forKey: .spotName)
        openTime = try values.decodeIfPresent(String.self, forKey: .openTime)
        introduction = try values.decodeIfPresent(String.self, forKey: .introduction)
        image = try values.decodeIfPresent(String.self, forKey: .image)
    }
}

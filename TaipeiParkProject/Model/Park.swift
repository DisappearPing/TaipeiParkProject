//
//  GetListDetailResult.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/11.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation
import MapKit

class Park: NSObject, Codable {
    let administrativeArea : String?
    let area : String?
    let image : String?
    let introduction : String?
    let latitude : String?
    let location : String?
    let longitude : String?
    let manageTelephone : String?
    let managementName : String?
    let openTime : String?
    let parkName : String?
    let parkType : String?
    let yearBuilt : String?
    let id : Int?
    
    enum CodingKeys: String, CodingKey {
        case administrativeArea = "AdministrativeArea"
        case area = "Area"
        case image = "Image"
        case introduction = "Introduction"
        case latitude = "Latitude"
        case location = "Location"
        case longitude = "Longitude"
        case manageTelephone = "ManageTelephone"
        case managementName = "ManagementName"
        case openTime = "OpenTime"
        case parkName = "ParkName"
        case parkType = "ParkType"
        case yearBuilt = "YearBuilt"
        case id = "_id"
    }
    
    init(from favoritePark: FavoritePark) {
        self.administrativeArea = favoritePark.administrativeArea
        self.area = favoritePark.area
        self.image = favoritePark.image
        self.introduction = favoritePark.introduction
        self.latitude = favoritePark.latitude
        self.location = favoritePark.location
        self.longitude = favoritePark.longitude
        self.manageTelephone = favoritePark.manageTelephone
        self.managementName = favoritePark.managementName
        self.openTime = favoritePark.openTime
        self.parkName = favoritePark.parkName
        self.parkType = favoritePark.parkType
        self.yearBuilt = favoritePark.yearBuilt
        self.id = favoritePark.id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        administrativeArea = try values.decodeIfPresent(String.self, forKey: .administrativeArea)
        area = try values.decodeIfPresent(String.self, forKey: .area)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        introduction = try values.decodeIfPresent(String.self, forKey: .introduction)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
        manageTelephone = try values.decodeIfPresent(String.self, forKey: .manageTelephone)
        managementName = try values.decodeIfPresent(String.self, forKey: .managementName)
        openTime = try values.decodeIfPresent(String.self, forKey: .openTime)
        parkName = try values.decodeIfPresent(String.self, forKey: .parkName)
        parkType = try values.decodeIfPresent(String.self, forKey: .parkType)
        yearBuilt = try values.decodeIfPresent(String.self, forKey: .yearBuilt)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
    }
}

extension Park: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(latitude ?? "") ?? 0.0, longitude: Double(longitude ?? "") ?? 0.0)
    }
    
    public var title: String? {
       return parkName
    }
    
    public var subtitle: String? {
        return administrativeArea
    }
}

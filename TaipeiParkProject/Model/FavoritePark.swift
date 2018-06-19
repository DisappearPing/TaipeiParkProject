//
//  FavoritePark.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/18.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation
import CoreData

@objc(FavoritePark)
class FavoritePark: NSManagedObject {
    @nonobjc open class func fetchRequest() -> NSFetchRequest<FavoritePark> {
        return NSFetchRequest<FavoritePark>(entityName: "FavoritePark")
    }
    
    @NSManaged var administrativeArea : String
    @NSManaged var area : String
    @NSManaged var image : String
    @NSManaged var introduction : String
    @NSManaged var latitude : String
    @NSManaged var location : String
    @NSManaged var longitude : String
    @NSManaged var manageTelephone : String
    @NSManaged var managementName : String
    @NSManaged var openTime : String
    @NSManaged var parkName : String
    @NSManaged var parkType : String
    @NSManaged var yearBuilt : String
    @NSManaged var id : Int
}

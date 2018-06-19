//
//  SpotCollectionViewCell.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

class SpotCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var spotNameLabel: UILabel!
    
    var spot: Spot?
    var cache = NSCache<AnyObject, AnyObject>()
    
    func setupWithSpot(_ spot: Spot) {
        self.spot = spot
        if let cacheImage = cache.object(forKey: spot.spotName as AnyObject) as? UIImage {
            spotImageView.image = cacheImage
        } else {
            spotImageView.imageFromServerURL(urlString: spot.image ?? "") {[weak self] (image) in
                guard let image = image, let aliveSelf = self else { return }
                aliveSelf.cache.setObject(image, forKey: aliveSelf.spot?.spotName as AnyObject)
            }
        }
        spotNameLabel.text = spot.spotName ?? ""
    }
}

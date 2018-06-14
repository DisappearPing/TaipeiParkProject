//
//  UIImageExtension.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/12.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromServerURL(urlString: String, _ callBack: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error)
                callBack(nil)
                return
            }
            let image = UIImage(data: data!)
            callBack(image)
            DispatchQueue.main.async(execute: { () -> Void in
                self.image = image
            })
            
        }).resume()
    }
}

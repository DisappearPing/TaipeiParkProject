//
//  SpotViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

class SpotViewController: UIViewController {

    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var spotNameLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    var spot: Spot?
    var cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = spot?.spotName ?? ""
        
        if let cacheImage = cache.object(forKey: (spot?.spotName ?? "") as AnyObject) as? UIImage {
            spotImageView.image = cacheImage
        } else {
            spotImageView.imageFromServerURL(urlString: spot?.image ?? "") {[weak self] (image) in
                guard let image = image, let aliveSelf = self else { return }
                aliveSelf.cache.setObject(image, forKey: (aliveSelf.spot?.spotName ?? "") as AnyObject)
            }
        }
        parkNameLabel.text = spot?.parkName ?? "未知"
        spotNameLabel.text = spot?.spotName ?? "未知"
        openTimeLabel.text = spot?.openTime ?? "00:00~00:00"
        introductionLabel.text = spot?.introduction ?? "未知"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  DetailParkInfoViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/19.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit

class DetailParkInfoViewController: UIViewController {

    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var parkTypeLabel: UILabel!
    @IBOutlet weak var AALocationLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var facilityNamesLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var spotsCollectionView: UICollectionView!
    
    var park: Park!
    var cache = NSCache<AnyObject, AnyObject>()
    var spots = [Spot]()
    var toDetailSpot: Spot?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = park.parkName
        
        if let cacheImage = cache.object(forKey: park.id as AnyObject) as? UIImage {
           parkImageView.image = cacheImage
        } else {
            parkImageView.imageFromServerURL(urlString: park.image ?? "") {[weak self] (image) in
                guard let image = image, let aliveSelf = self else { return }
                aliveSelf.cache.setObject(image, forKey: aliveSelf.park.id as AnyObject)
            }
        }
        parkNameLabel.text = park.parkName ?? "未知"
        parkTypeLabel.text = park.parkType ?? "未知"
        AALocationLabel.text = "\(park.administrativeArea ?? "未知") \(park.location ?? "未知")"
        openTimeLabel.text = park.openTime ?? "00:00~00:00"
        facilityNamesLabel.text = "讀取中..."
        introductionLabel.text = park.introduction ?? "未知"
        
        APIManager.shared.getFacilitiesWithParkName(park.parkName ?? "") { (result, error) in
            guard error == nil else {
                print("error = \(error)")
                return
            }
            print("result = \(result)")
//            result!.result?.results?.reduce("", { (result, facility) -> Result in
//                result +
//            })
            
            let facilities = result?.result?.results?.reduce("") {
                $0 + " " + ($1.facilityName ?? "")
            }
            
            DispatchQueue.main.async {
                self.facilityNamesLabel.text = facilities ?? ""
            }
        }
        
        APIManager.shared.getSpotsWithParkName(park.parkName ?? "") { (result, error) in
            guard error == nil else {
                print("error = \(error)")
                return
            }
            print("result = \(result)")
            
            self.spots = result?.result?.results ?? []
            
            DispatchQueue.main.async {
               self.spotsCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toDetail",
            let toDetailSpot = toDetailSpot {
            let destinationVC = segue.destination as! SpotViewController
            destinationVC.spot = toDetailSpot
        }
    }
}

// MARK: UICollectionViewDataSource

extension DetailParkInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SpotCollectionViewCell
        cell.setupWithSpot(spots[indexPath.row])
        return cell
    }
}

// MARK:

extension DetailParkInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toDetailSpot = (collectionView.cellForItem(at: indexPath) as! SpotCollectionViewCell).spot
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
}



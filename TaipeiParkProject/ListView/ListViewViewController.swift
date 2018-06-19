//
//  ListViewViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/10.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit
import CoreData

class ListViewViewController: UIViewController {

    @IBOutlet weak var parkTableView: UITableView!
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    var parks = [Park]()
    var favoriteParks = [FavoritePark]()
    var selectedPark: Park?
    var cache = NSCache<AnyObject, AnyObject>()
    var isLoading = false
    var toDetailPark: Park?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        hidesBottomBarWhenPushed = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getListDataWithPage(0)
        
        // get favorite parks from coreData
        
       fetchFavoriteParks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tabBarController?.selectedIndex = 1
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toDetail",
            let toDetailPark = toDetailPark {
            let destinationVC = segue.destination as! DetailParkInfoViewController
            destinationVC.park = toDetailPark
        }
    }
}

// MARK: Custom Method

extension ListViewViewController {
    func getListDataWithPage(_ page: Int) {
        APIManager.shared.getListDataWithPage(page) { [unowned self] (result, error) in
            guard error == nil else {
                print("error = \(error)")
                return
            }
            print("result = \(result)")
            let newParks = result!.result?.results ?? []
            if page == 0 {
                self.parks = newParks
            } else {
                self.parks += newParks
            }
           
            DispatchQueue.main.async {
                self.parkTableView.reloadData()
                self.isLoading = false
                self.removeRefreshFootView()
            }
        }
    }
    
    func setUpRefreshFootView() {
        let indicatorFooter = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: parkTableView.frame.size.width, height: 44)))
        indicatorFooter.color = UIColor.darkGray
        indicatorFooter.startAnimating()
        
        parkTableView.tableFooterView = indicatorFooter
    }
    
    func removeRefreshFootView() {
        parkTableView.tableFooterView = UIView()
    }
    
    @objc func cellMapButtonAction(_ sender: UIButton) {
        selectedPark = parks[sender.tag]
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func addFavoritePark(_ sender: UIButton) {
        let selectedPark = parks[sender.tag]
        let favoritePark: FavoritePark
        let existFavoriteParks = favoriteParks.filter() {
            $0.id == selectedPark.id ?? -1
        }
        
        if existFavoriteParks.count != 0,
            let toDeletePark = existFavoriteParks.first {
            // delete
            managedObjectContext.delete(toDeletePark)
        } else {
        
        // add
        
            favoritePark = FavoritePark(context: managedObjectContext)
            favoritePark.administrativeArea = selectedPark.administrativeArea ?? ""
            favoritePark.area = selectedPark.area ?? ""
            favoritePark.id = Int(selectedPark.id ?? -1)
            favoritePark.image = selectedPark.image ?? ""
            favoritePark.introduction = selectedPark.introduction ?? ""
            favoritePark.latitude = selectedPark.latitude ?? ""
            favoritePark.longitude = selectedPark.longitude ?? ""
            favoritePark.managementName = selectedPark.managementName ?? ""
            favoritePark.manageTelephone = selectedPark.manageTelephone ?? ""
            favoritePark.openTime = selectedPark.openTime ?? ""
            favoritePark.parkName = selectedPark.parkName ?? ""
            favoritePark.parkType = selectedPark.parkType ?? ""
            favoritePark.yearBuilt = selectedPark.yearBuilt ?? ""
        
        }
            
        do {
            try managedObjectContext.save()
//            afterDelay(0.6) {
//                hudView.hide()
//                self.navigationController?.popViewController(animated: true)
//            }
            print("coreData saved !!")
            fetchFavoriteParks()
            parkTableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
        } catch {
//            fatalCoreDataError(error)
            print("coreData error : \(error)")
        }
    }
    
    func fetchFavoriteParks() {
        let fetchRequest = NSFetchRequest<FavoritePark>(entityName: "FavoritePark")
        do {
            favoriteParks = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("fetch error = \(error)")
        }
    }
}

// MARK: UITableViewDataSource

extension ListViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListViewBasicTableViewCell
        let cellData = parks[indexPath.row]
        
        cell.parkNameLabel.text = cellData.parkName
        cell.administrativeAreaLabel.text = cellData.administrativeArea
        cell.introductionLabel.text = cellData.introduction
        if let cacheImage = cache.object(forKey: cellData.id as AnyObject) as? UIImage {
            cell.parkImageView.image = cacheImage
        } else {
            cell.parkImageView.imageFromServerURL(urlString: cellData.image ?? "") {[weak self] (image) in
                guard let image = image, let aliveSelf = self else { return }
                aliveSelf.cache.setObject(image, forKey: cellData.id as AnyObject)
            }
        }
        
        cell.mapButton.addTarget(self, action: #selector(cellMapButtonAction(_:)), for: .touchUpInside)
        cell.mapButton.tag = indexPath.row
        
        cell.favoriteStarButton.addTarget(self, action: #selector(addFavoritePark(_:)), for: .touchUpInside)
        cell.favoriteStarButton.tag = indexPath.row
        
        if favoriteParks.contains(where: { (favoritePark) -> Bool in
            favoritePark.id == cellData.id ?? -1
        }) {
            cell.favoriteStarButton.setTitle("★", for: .normal)
            cell.favoriteStarButton.setTitleColor(UIColor.yellow, for: .normal)
        } else {
            cell.favoriteStarButton.setTitle("☆", for: .normal)
            cell.favoriteStarButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toDetailPark = parks[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
}

// MARK: UITableViewDelegate

extension ListViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard parks.count == indexPath.row + 1 && parks.count % 15 == 0 else { return }
        if ( indexPath.row + 1) % 15 == 0 && isLoading == false {
            setUpRefreshFootView()
            isLoading = true
            getListDataWithPage(parks.count + 1)
        } else {
            removeRefreshFootView()
        }
    }
}

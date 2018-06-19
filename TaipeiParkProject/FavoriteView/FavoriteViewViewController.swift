//
//  FavoriteViewViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/10.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit
import CoreData

class FavoriteViewViewController: UIViewController {

    @IBOutlet weak var favoriteTableView: UITableView!
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    lazy var fetchedResultsController: NSFetchedResultsController<FavoritePark> = {
        let fetchRequest = NSFetchRequest<FavoritePark>()
        let entity = FavoritePark.entity()
        fetchRequest.entity = entity
        let sortDescription = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescription]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    lazy var listVC: ListViewViewController = {
        return (self.tabBarController?.viewControllers?.first as! UINavigationController).topViewController as! ListViewViewController
    }()
    var favoriteParks = [FavoritePark]() {
        didSet {
            favoriteTableView.reloadData()
        }
    }
    var cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        performFetch()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        performFetch()
    }

    deinit {
        fetchedResultsController.delegate = nil
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

// MARK: Custom Method

extension FavoriteViewViewController {
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                favoriteParks = fetchedObjects
            }
        } catch {
//            fatalCoreDataError(error)
            print("coreData error : \(error)")
        }
    }
    
    @objc func cellMapButtonAction(_ sender: UIButton) {
        listVC.selectedPark = Park(from: favoriteParks[sender.tag])
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func addFavoritePark(_ sender: UIButton) {
    
    }
}

// MARK: UITableViewDataSource

extension FavoriteViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteParks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListViewBasicTableViewCell
        let cellData = favoriteParks[indexPath.row]

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
        
        cell.favoriteStarButton.setTitle("★", for: .normal)
        cell.favoriteStarButton.setTitleColor(UIColor.yellow, for: .normal)
        
        return cell
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension FavoriteViewViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                favoriteTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                favoriteTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                favoriteTableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            favoriteTableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            favoriteParks = fetchedObjects as! [FavoritePark]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        favoriteTableView.endUpdates()
    }
}

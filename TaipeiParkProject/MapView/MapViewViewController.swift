//
//  MapViewViewController.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/10.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var listVC: ListViewViewController = {
        return (self.tabBarController?.viewControllers?.first as! UINavigationController).topViewController as! ListViewViewController
    }()
    lazy var managedObjectContext: NSManagedObjectContext = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    var favoriteParks = [FavoritePark]()
    var locationManager: CLLocationManager!
    var selectedPark: Park?
    var cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // do map part
        
        setupLocationManagerAndUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedPark = listVC.selectedPark {
            self.selectedPark = selectedPark
            listVC.selectedPark = nil
            locationManager.stopUpdatingLocation()
            // clear map
            
            if mapView.annotations.count > 0 {
                mapView.removeAnnotations(mapView.annotations)
            }
            
            mapView.addAnnotations(listVC.parks)
            let isContainsSelectedAnnotation = mapView.annotations.contains() {
                $0 as! Park == selectedPark
            }
            if isContainsSelectedAnnotation == false {
                mapView.addAnnotation(selectedPark)
            }
            mapView.selectAnnotation(selectedPark, animated: true)
            
            let center = CLLocationCoordinate2DMake( Double(selectedPark.latitude ?? "") ?? 25.046256, Double(selectedPark.longitude ?? "") ?? 121.517373)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            
            mapView.setRegion(region, animated: true)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("mapView.annotations = \(mapView.annotations)")
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

// MARK: Custom Method

extension MapViewViewController {
    func setupLocationManagerAndUpdate() {
        // get location
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchFavoriteParks() {
        let fetchRequest = NSFetchRequest<FavoritePark>(entityName: "FavoritePark")
        do {
            favoriteParks = try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("fetch error = \(error)")
        }
    }
    
    @objc func addFavoritePark(_ sender: UIButton) {
        let favoriteParks = self.favoriteParks.count != 0 ? self.favoriteParks : listVC.favoriteParks

        let existFavoriteParks = favoriteParks.filter() {
            $0.id == sender.tag
        }
        let selectedPark = listVC.parks.filter { (park) -> Bool in
            park.id ?? -1 == sender.tag
        }.first!
        let favoritePark: FavoritePark

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
            mapView.removeAnnotation(selectedPark)
            mapView.addAnnotation(selectedPark)
            mapView.selectAnnotation(selectedPark, animated: true)
        } catch {
            //            fatalCoreDataError(error)
            print("coreData error : \(error)")
        }
    }
}

// MARK:

extension MapViewViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myPin"

        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.animatesDrop = false
        }
        
        let parkAnnotation = annotation as! Park
        
        let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
        if let cacheImage = cache.object(forKey: parkAnnotation.id as AnyObject) as? UIImage {
            leftIconView.image = cacheImage
        } else {
            leftIconView.imageFromServerURL(urlString: parkAnnotation.image ?? "", { [weak self] (image) in
                guard let image = image, let aliveSelf = self else { return }
                aliveSelf.cache.setObject(image, forKey: parkAnnotation.id as AnyObject)
            })
        }
        
        let rightFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
        rightFavoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)

        let favoriteParks = self.favoriteParks.count != 0 ? self.favoriteParks : listVC.favoriteParks
        
        if favoriteParks.contains(where: { (favoritePark) -> Bool in
            favoritePark.id == parkAnnotation.id ?? -1
        }) {
            rightFavoriteButton.setTitle("★", for: .normal)
            rightFavoriteButton.setTitleColor(UIColor.yellow, for: .normal)
        } else {
            rightFavoriteButton.setTitle("☆", for: .normal)
            rightFavoriteButton.setTitleColor(UIColor.lightGray, for: .normal)
        }
        
        rightFavoriteButton.tag = parkAnnotation.id ?? -1
        rightFavoriteButton.addTarget(self, action: #selector(addFavoritePark(_:)), for: .touchUpInside)
        
        annotationView?.leftCalloutAccessoryView = leftIconView
        annotationView?.rightCalloutAccessoryView = rightFavoriteButton
        
        annotationView?.pinTintColor = UIColor.blue
        
        print("annotation = \(annotation)")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("taped")
    }
}

// MARK: CLLocationManagerDelegate

extension MapViewViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last ?? CLLocation(latitude: 25.046256, longitude: 121.517373)
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
}

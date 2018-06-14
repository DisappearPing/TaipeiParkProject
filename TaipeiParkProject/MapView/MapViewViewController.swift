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

class MapViewViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var listVC: ListViewViewController = {
        return (self.tabBarController?.viewControllers?.first as! UINavigationController).topViewController as! ListViewViewController
    }()
    var locationManager: CLLocationManager!
    var selectedPark: Park?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let listVC = (self.tabBarController?.viewControllers?.first as! UINavigationController).topViewController as! ListViewViewController
        
        // do map part
        
//        let geoCoder = CLGeocoder()
//        geoCoder.geocoder
        
        setupLocationManagerAndUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedPark = listVC.selectedPark {
            listVC.selectedPark = nil
            self.selectedPark = selectedPark
            locationManager.stopUpdatingLocation()
//            let geoCoder = CLGeocoder()
//            geoCoder.reverseGeocodeLocation(CLLocation(latitude: Double(selectedPark.latitude ?? "") ?? 25.046256, longitude: Double(selectedPark.longitude ?? "") ?? 121.517373), completionHandler: { (placemarks, error) in
//                guard error == nil else {
//                    print("error = \(error!)")
//                    return
//                }
//
//            })
//
  
            var otherAnnotations = [MKPointAnnotation]()
            listVC.parks.forEach() {
                let annotation = MKPointAnnotation()
                annotation.title = $0.parkName
                annotation.subtitle = $0.administrativeArea
                annotation.coordinate = CLLocationCoordinate2DMake( Double($0.latitude ?? "") ?? 0.0, Double($0.longitude ?? "") ?? 0.0)
                otherAnnotations.append(annotation)
            }
            
//            mapView.addAnnotations(otherAnnotations)
            mapView.showAnnotations(otherAnnotations, animated: true)
//            let location = locations.last ?? CLLocation(latitude: 25.046256, longitude: 121.517373)
            
            let center = CLLocationCoordinate2DMake( Double(selectedPark.latitude ?? "") ?? 25.046256, Double(selectedPark.longitude ?? "") ?? 121.517373)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            
            mapView.setRegion(region, animated: true)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let selectedPark = self.selectedPark else { return }
        let selectedAnnotation = MKPointAnnotation()
        selectedAnnotation.title = selectedPark.parkName
        selectedAnnotation.subtitle = selectedPark.administrativeArea
        selectedAnnotation.coordinate = CLLocationCoordinate2DMake( Double(selectedPark.latitude ?? "") ?? 0.0, Double(selectedPark.longitude ?? "") ?? 0.0)
        mapView.selectAnnotation(selectedAnnotation, animated: true)
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
        }
        
        
        
        return annotationView
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

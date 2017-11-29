//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 29.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        
        let centerLat =  UserDefaults.standard.double(forKey: "centerLat")
        let centerLong =  UserDefaults.standard.double(forKey: "centerLong")
        let latDelta =  UserDefaults.standard.double(forKey: "latDelta")
        let longDelta =  UserDefaults.standard.double(forKey: "longDelta")
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong), MKCoordinateSpanMake(latDelta, longDelta)), animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "centerLat")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "centerLong")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "longDelta")
        
    }
    
}


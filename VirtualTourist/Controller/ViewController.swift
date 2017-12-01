//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 29.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin: Pin!
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            fetchedResultsController.delegate = self
            executeSearch()
            fetchAllPins()
        }
    }
    
    var stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumSegue" {
            if let nextVC = segue.destination as? AlbumViewController {
                nextVC.pin = self.selectedPin
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        
        let centerLat =  UserDefaults.standard.double(forKey: "centerLat")
        let centerLong =  UserDefaults.standard.double(forKey: "centerLong")
        let latDelta =  UserDefaults.standard.double(forKey: "latDelta")
        let longDelta =  UserDefaults.standard.double(forKey: "longDelta")
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong), MKCoordinateSpanMake(latDelta, longDelta)), animated: true)
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "centerLat")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "centerLong")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "longDelta")
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        
        fr.predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", (view.annotation?.coordinate.latitude)!, (view.annotation?.coordinate.longitude)!)
        
        do {
            let fetchedResults = try stack.context.fetch(fr) as! [Pin]
            
            print(fetchedResults.count)
            
            if let pin = fetchedResults.first {
                print("\(pin)")
                
                self.selectedPin = pin
            }
        } catch {
            print("catch")
        }
        
         performSegue(withIdentifier: "albumSegue", sender: self)
                
    }
    
    
    @IBAction func longPress(recognizer:UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            
            let location = recognizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, lastPage: 1, context: fetchedResultsController.managedObjectContext)
            print("Added a new pin: \(pin)")
            stack.save()
            
        }
    }
    
    func fetchAllPins() {
        //clear annotations
        print("fetchAllPins \(fetchedResultsController.fetchedObjects?.count)")
        
        mapView.removeAnnotations(mapView.annotations)
        
        
        
        for pin in fetchedResultsController.fetchedObjects as! [Pin] {
            print("pin found lat \(pin.latitude) long \(pin.longitude) page \(pin.lastPage)")
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
            annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
}





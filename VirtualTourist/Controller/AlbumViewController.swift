//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 29.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemChanges = [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)]()
    
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    @IBOutlet weak var newCollectionButton: UIButton!
    
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            fetchedResultsController.delegate = self
            executeSearch()
            
            if fetchedResultsController.fetchedObjects?.count == 0 {
                
                print("no data")
               
                newCollectionClicked(nil)
               
                
            } else {
                print("Downloaded \(fetchedResultsController.fetchedObjects?.count)")
                performUIUpdatesOnMain {
                    self.newCollectionButton.isEnabled = true
                }
            }
            
        }
    }
    
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newCollectionButton.isEnabled = false
        
        print("\(pin)")
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", self.pin)
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        //Add selected pin to map
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        mapView.addAnnotation(annotation)
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude), MKCoordinateSpanMake(0.005, 0.005)), animated: true)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @IBAction func newCollectionClicked(_ sender: Any?) {
        
        for image in fetchedResultsController.fetchedObjects as! [Image]{
            self.stack.context.delete(image)
        }
        
        
        print("Item count after removal \(fetchedResultsController.fetchedObjects?.count)")
        
        FlickrClient.sharedInstance().searchImages(pin: pin, completionHandler:({error in
            
            if error == nil {
                
                    self.stack.save()
                    self.executeSearch()
                    self.collectionView.reloadData()
                    self.newCollectionButton.isEnabled = true
                
            }
            
        }))
        
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

fileprivate let itemsPerRow: CGFloat = 3
fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)


extension AlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = fetchedResultsController.object(at: indexPath) as! Image
        
        self.stack.context.delete(image)
        
        self.stack.save()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell",
                                                      for: indexPath) as! FlickrCollectionViewCell
        
        // Configure the cell
        
        let image  = fetchedResultsController.object(at: indexPath) as! Image
        
        if image.imageData != nil {
            cell.imageView.image = UIImage(data: (image.imageData! as Data))
        } else {
            
            FlickrClient.sharedInstance().downloadImage(url: image.url!, completionHandler: ({data, error in
                
                if error == nil {
                    
                    performUIUpdatesOnMain {
                        cell.imageView.image = UIImage(data: data!)
                        
                    }
                    
                    image.imageData = data! as NSData
                    
                }
                
                
            }))
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}


extension AlbumViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a fetch \(e)")
            }
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.itemChanges.removeAll()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.itemChanges.append((type, indexPath, newIndexPath))
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    
        collectionView?.performBatchUpdates({
            
            for change in self.itemChanges {
                switch change.type {
                case .insert: self.collectionView?.insertItems(at: [change.newIndexPath!])
                case .delete: self.collectionView?.deleteItems(at: [change.indexPath!])
                case .update: self.collectionView?.reloadItems(at: [change.indexPath!])
                case .move:
                    self.collectionView?.deleteItems(at: [change.indexPath!])
                    self.collectionView?.insertItems(at: [change.newIndexPath!])
                }
            }
            
        }, completion: { finished in
            self.itemChanges.removeAll()
        })
    }
    
}


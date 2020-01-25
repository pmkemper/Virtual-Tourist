//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Philip Kemper on 23/01/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!

    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController() {
        if dataController == nil {
            print("ITS NIL YOU GUYS!")
        }
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView.delegate = self
        
        // add UILongPressureGestureRecognizer to set annotations with a long press.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
        setupFetchedResultsController()
        refreshAnnotations()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func refreshAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [Pin])
    }


    // code found at https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            // get the coordinate of the long press
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            
            // save the new pin
            let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: dataController.viewContext)
            try? dataController.viewContext.save()
        }
    }
}

extension TravelMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Hey")
    }
}

extension TravelMapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let annotation = anObject as! MKAnnotation
            self.mapView.addAnnotation(annotation)
            break
        default:
            break
        }
    }
}

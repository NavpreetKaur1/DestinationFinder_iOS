//
//  MapViewController.swift
//  Assignment1
//
//  Created by Xcode User on 2018-10-06.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class MapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager = CLLocationManager()
    
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.739534)
    
    var circle = MKCircle()
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    @IBOutlet var myTableView : UITableView!
    @IBOutlet var mySegmentedView : UISegmentedControl!
    @IBOutlet var wayPoint1 : UITextField!
    @IBOutlet var wayPoint2 : UITextField!
    @IBOutlet var labelTxt : UILabel!
    
    var routeSteps = ["Enter a destination to see the steps"]
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    let regionRadius : CLLocationDistance = 10000
    func centreMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        myMapView.setRegion(coordinateRegion, animated: true)     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        centreMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Starting at Sheridan College"
        self.myMapView.addAnnotation(dropPin)
        self.myMapView.selectAnnotation(dropPin, animated: true)
        circle = MKCircle(center: initialLocation.coordinate, radius: 15000)
        
        self.myMapView.add(circle)
        
        
    }

    @IBAction func showOnMap(){
       segmentChanged()
        
    }
    
    func segmentChanged(){
        let i = mySegmentedView.selectedSegmentIndex
        
        if i == 0{
           findLoc(i: 0)
        }
            
        else if i == 1{
            findLoc(i: 1)
        }
            
        else {
          findLoc(i: 2)
        }
    }
    
    @IBAction func findNewLocation(){
        findLoc(i: 0)
            }
    
    func findLoc(i: Int){
        
        var locEnter = ""
        
        let geoCoder = CLGeocoder()
        
        if i == 0
        {
            locEnter = tbLocEntered.text!
        }
        else if i == 1
        {
            locEnter = wayPoint1.text!
        }
        
        else
        {
            locEnter = wayPoint2.text!
        }
        
        geoCoder.geocodeAddressString(locEnter, completionHandler:
            
            {(placemarks, error) -> Void in
                
                if(error != nil){
                    print("Error", error)
                }
                
                if let placemark = placemarks?.first{
                    
                    let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                    
                    let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    
                    self.centreMapOnLocation(location: newLocation)
                    
                        if (self.initialLocation.distance(from: placemark.location!) ) < 15000
                        {
                            self.labelTxt.text = "New location is inside the boundary"
                        }
                        
                        else{
                            self.labelTxt.text = "New location is outside the boundary"
                        }
                    
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = coordinates
                    dropPin.title = placemark.name
                    self.myMapView.addAnnotation(dropPin)
                    self.myMapView.selectAnnotation(dropPin, animated: true)
                    
                    let request = MKDirectionsRequest()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate, addressDictionary: nil))
                    
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates, addressDictionary: nil))
                    request.requestsAlternateRoutes = false
                    request.transportType = .automobile
                    
                    
                    let directions = MKDirections(request: request)
                    directions.calculate(completionHandler:
                        
                        {[unowned self] response, error in
                            
                            for route in (response?.routes)!{
                                
                                self.myMapView.add(route.polyline, level:MKOverlayLevel.aboveRoads)
                                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                                
                                self.routeSteps.removeAll()
                                
                                for step in route.steps{
                                    self.routeSteps.append(step.instructions)
                                }
                                self.myTableView.reloadData()
                            }
                            
                            
                        }
                    )
                    
                }
        }
        )

    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline{
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
            return renderer
        }
        
        else if overlay is MKCircle{
        let renderer = MKCircleRenderer(circle: overlay as! MKCircle)
        renderer.strokeColor = UIColor.blue
        renderer.alpha = 0.3
        renderer.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.3)
            let newLoc = CLLocation(latitude: 43.642509, longitude: -79.387039)
            
            let mapPoint = MKMapPointForCoordinate(newLoc.coordinate)
            let cgpoint = renderer.point(for: mapPoint)
            
            if renderer.path.contains(cgpoint){
            print("in there")
            }
            
            return renderer
        }
       return MKOverlayRenderer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
        UITableViewCell()
        
        tableCell.textLabel?.text = routeSteps[indexPath.row]
        
        
        return tableCell
        
        
    }
}

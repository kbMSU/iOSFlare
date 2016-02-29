//
//  ViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/19/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, ContactModuleDelegate {
    
    // MARK: Constants
    let mapViewRadius: CLLocationDistance = 1000
    let locationAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    let locationManager: CLLocationManager = CLLocationManager()
    let geoCoder : CLGeocoder = CLGeocoder()
    let defaultLocationText = "Grabbing address ..."
    let geoCoderUserIntiatedCancelCode: Int = 10
    
    // MARK: Properties
    var userLocation : CLLocation?
    var userAddress : String?
    var contactsModule : ContactsModule?
    var initialized : Bool = false

    // MARK: Outlets
    @IBOutlet weak var sendFlareButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var topLevelView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var locationMarker: UIImageView!
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsModule = ContactsModule(delegate: self)
        
        addressLabel.layer.borderColor = UIColor.lightGrayColor().CGColor
        addressLabel.layer.borderWidth = 0.3
        addressLabel.layer.shadowRadius = 3
        addressLabel.layer.shadowOpacity = 0.6
        addressLabel.layer.shadowOffset = CGSize(width: 3, height: 3)
        addressLabel.layer.shadowColor = UIColor.grayColor().CGColor
        
        /*
        sendFlareButton.layer.shadowRadius = 3
        sendFlareButton.layer.shadowOpacity = 0.6
        sendFlareButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        sendFlareButton.layer.shadowColor = UIColor.grayColor().CGColor
        */
        
        locationManager.desiredAccuracy = locationAccuracy
        locationManager.delegate = self
        
        mapView.delegate = self

        addressLabel.text = defaultLocationText
        
        locationMarker.hidden = true
        
        mapView.showsUserLocation = false
        
        navigationController!.navigationBar.tintColor = Constants.flareRedColor
        
        isBusy()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialized {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            updateLocation()
            setInitialized()
            mapView.showsUserLocation = true
            
            locationManager.requestLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Location Manager Delegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            updateLocation()
            setInitialized()
            mapView.showsUserLocation = true
            
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, let topLocation = locations.first {
            userLocation = topLocation
            centerMapOnUserLocation()
            updateAddress()
        } else {
            displayError("Unable to get your location")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
        displayError("Unable to get your location")
        setInitialized()
    }
    
    // MARK: Map Delegate
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoordinate = mapView.centerCoordinate
        let centerLocation = CLLocation(coordinate: centerCoordinate, altitude: mapViewRadius, horizontalAccuracy: locationAccuracy, verticalAccuracy: locationAccuracy, timestamp: NSDate())
        userLocation = centerLocation
        updateAddress()
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "SendFlareClickSegue":
                let nextSceneViewController = segue.destinationViewController as! SendFlareContactsViewController
                nextSceneViewController.userLocation = userLocation
            default:
                return
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SendFlareClickSegue" {
            // If we are authorized to get contacts
            if contactsModule!.isAuthorized() {
                // We dont have contacts yet, try again here
                if DataModule.contacts.isEmpty {
                    getContacts()
                    return false
                // We are authorized to get contacts and also have gotten them. Segue can fire
                } else {
                    return true
                }
            // We are not authorized to get contacts, lets fix that here
            } else {
                authorizeContacts()
                return false
            }
        }
        return true
    }
    
    @IBAction func unwindBackToMapView(sender: UIStoryboardSegue) {
        let source = sender.sourceViewController as? ConfirmFlareViewController
        if source != nil {
            for contact in DataModule.contacts where contact.isSelected {
                contact.isSelected = false
            }
        }
    }
    
    // MARK: ContactModuleDelegate
    func retreiveResult(result: ErrorTypes) {
        doneBeingBusy()
        switch result {
        case .None:
            performSegueWithIdentifier("SendFlareClickSegue", sender: nil)
        case .Error:
            displayError("There was a problem getting your contacts")
        case .Unauthorized:
            displayError("You did not authorize us to access your contacts. We need to do this to enable you to flare to them")
        }
    }
    
    // MARK: Helper Methods
    func displayError(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func authorizeContacts() {
        let authorizeAlert = UIAlertController(title: "Permission Needed", message: "Can we access your contacts ? We need to do this to enable you to flare to them", preferredStyle: .Alert)
        authorizeAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(UIAlertAction) -> Void in
            self.isBusy()
            self.contactsModule!.authorizeContacts()
        }))
        authorizeAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
        presentViewController(authorizeAlert, animated: true, completion: nil)
    }
    
    func getContacts() {
        isBusy()
        contactsModule!.authorizeContacts()
    }
    
    func centerMapOnUserLocation() {
        if let location = userLocation {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, mapViewRadius, mapViewRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func updateAddress() {
        geoCoder.cancelGeocode()
        userAddress = defaultLocationText
        geoCoder.reverseGeocodeLocation(userLocation!, completionHandler: {placemarks,error in
            if error != nil && error?.code != self.geoCoderUserIntiatedCancelCode {
                self.displayError("Unable to get your address")
            }
            
            if let places = placemarks {
                if places.count == 0 {
                    return
                }
                let topPlace = places[0] as CLPlacemark
                self.userAddress = ""
                if let bldgNumber = topPlace.subThoroughfare {
                    self.userAddress = bldgNumber + ", "
                }
                if let street = topPlace.thoroughfare {
                    self.userAddress?.appendContentsOf(street)
                }
                if let address = self.userAddress where self.userAddress != "" {
                    self.addressLabel.text = address
                } else {
                    self.addressLabel.text = self.defaultLocationText
                }
            }
        })
    }
    
    func updateLocation() {
        userLocation = locationManager.location
        centerMapOnUserLocation()
        updateAddress()
    }
    
    func setInitialized() {
        initialized = true;
        
        doneBeingBusy()
        
        locationMarker.hidden = false
    }
    
    func isBusy() {
        topLevelView.userInteractionEnabled = false
        
        overlayView.hidden = false
        
        loadingIndicator.hidden = false
        loadingIndicator.startAnimating()

    }
    
    func doneBeingBusy() {
        topLevelView.userInteractionEnabled = true
        
        overlayView.hidden = true
        
        loadingIndicator.hidden = true
        loadingIndicator.stopAnimating()
    }
}


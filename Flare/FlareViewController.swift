//
//  FlareViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MapKit

class FlareViewController: UIViewController, ContactModuleDelegate, BackendModuleDelegate {
    
    // MARK: Variables
    
    var flare : Flare!
    var contactModule : ContactsModule!
    var backendModule : BackendModule!
    
    var response : Bool = false
    var contactFullName : String?
    
    // MARK: Outlets
    
    @IBOutlet weak var dissmissBarButton: UIBarButtonItem!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var flareTypeMessage: UILabel!
    @IBOutlet weak var flareMessage: UILabel!
    @IBOutlet weak var respondButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapLocationMarker: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactName.text = flare.name
        contactImage.image = flare.image
        flareMessage.text = flare.message
        
        switch flare.type {
        case .IncomingFlare:
            flareTypeMessage.text = "has flared you"
        case .OutgoingFlare:
            flareTypeMessage.text = "You sent a flare"
            respondButton.hidden = true
        case .IncomingResponse:
            flareTypeMessage.text = "has responded to your flare"
            respondButton.hidden = true
        case .OutgoingResponse:
            flareTypeMessage.text = "You responded to a flare"
            respondButton.hidden = true
        }
        
        contactImage.clipsToBounds = true
        contactImage.layer.cornerRadius = contactImage.frame.height/2
        
        if let latitude = flare.latitude, let longitude = flare.longitude {
            let location = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
            let region = MKCoordinateRegionMakeWithDistance(location,1000,1000)
            mapView.setRegion(region, animated: false)
        } else {
            mapView.hidden = true
            mapLocationMarker.hidden = true
        }
        
        contactModule = ContactsModule(delegate: self)
        if !contactModule!.isAuthorized() {
            let alert = UIAlertController(title: "Permission", message: "We can see if the person who flared you is in your contacts. Can we check ?", preferredStyle: .Alert)
            let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action:UIAlertAction) -> Void in
                self.isBusy()
                self.contactModule!.authorizeContacts()
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)
            presentViewController(alert, animated: false, completion: nil)
        } else {
            doneBeingBusy()
        }
        
        backendModule = BackendModule(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Contact Module Delegate
    
    func retreiveResult(result: ErrorTypes) {
        doneBeingBusy()
        
        if result == ErrorTypes.None {
            checkContacts()
        }
    }
    
    // MARK: Backend Module Delegate
    
    func sendFlareResponseSuccess() {
        if response {
            doneBeingBusy()
            let regionDistance:CLLocationDistance = 10000
            let location = CLLocationCoordinate2DMake(Double(flare.latitude!)!, Double(flare.longitude!)!)
            let region = MKCoordinateRegionMakeWithDistance(location, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: region.span)
            ]
            let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = contactFullName ?? flare.name
            mapItem.openInMapsWithLaunchOptions(options)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        doneBeingBusy()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendFlareResponseError(error: ErrorType) {
        doneBeingBusy()
        let alert = UIAlertController(title: "Error", message: "Something went wrong while sending the message", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func respondAction(sender: UIButton) {
        let alert = UIAlertController(title: "Response", message: "Are you going to your friends flare ?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.isBusy()
            self.backendModule!.declineFlare(self.flare.phoneNumber, message: DataModule.defaultDeclineMessage)
        })
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.isBusy()
            self.response = true
            self.backendModule!.acceptFlare(self.flare.phoneNumber, message: DataModule.defaultAcceptMessage)
        })
        alert.addAction(noAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func dismissButtonAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    func checkContacts() {
        var matchingContact : Contact? = nil
        for contact in DataModule.contacts where contact.hasFlare {
            for phone in contact.phoneNumbers where phone.hasFlare {
                if phone.digits.containsString(flare.phoneNumber) {
                    matchingContact = contact
                    break
                }
            }
        }
        
        if let contact = matchingContact {
            contactImage.image = contact.image
            contactFullName = contact.firstName+" "+contact.lastName
            contactName.text = contactFullName
        }
    }
    
    func isBusy() {
        overlayView.hidden = false
        respondButton.enabled = false
        if let button = dissmissBarButton {
            button.enabled = false
        }
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        respondButton.enabled = true
        if let button = dissmissBarButton {
            button.enabled = true
        }
    }
}

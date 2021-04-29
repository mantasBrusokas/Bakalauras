//
//  LocationPickerViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-25.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var isPickable = true
    private var locManager = CLLocationManager()
    
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    init(coordinates: CLLocationCoordinate2D?) {
        self.coordinates = coordinates
        self.isPickable = true
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendButtonTapped))
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        }
        else {
            // just showing location
            guard let coordinates = self.coordinates else {
                print("returnas")
                return
            }

            // drop a pin on that location
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
        }
        view.addSubview(map)
        
        locManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation1 = locManager.location else {
                return
            }
            print(currentLocation1.coordinate.latitude)
            print(currentLocation1.coordinate.longitude)
            map.centerToLocationCity(currentLocation1)
            let pin = MKPointAnnotation()
            pin.title = "Current location"
            pin.coordinate = currentLocation1.coordinate
            map.addAnnotation(pin)
        }
        
    }

    @objc func sendButtonTapped() {
        guard let coordinates = coordinates else {
            return
        }
        
        self.alert(message: "Coordinates selected")
        completion?(coordinates)
        
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "",
                                      message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            
        }
    }

    @objc func didTapMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates

        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }

        // drop a pin on that location
        let pin = MKPointAnnotation()
        pin.title = "Start point"
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }

}

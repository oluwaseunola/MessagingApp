//
//  LocationPicker.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-13.
//

import UIKit
import CoreLocation
import MapKit

class LocationPicker: UIViewController {
   
    public var completion : ((CLLocationCoordinate2D)->Void)?
    private var finalLocation : CLLocationCoordinate2D?
    
    let map : MKMapView = {
        let map = MKMapView()
        
        
        
        return map
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone))
        title = "Drop your location📍"

        view.addSubview(map)
        map.isUserInteractionEnabled = true
        
        view.backgroundColor = .systemBackground
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        map.addGestureRecognizer(gesture)
       
      
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func didTapDone(){
        
        if let finalLocation = finalLocation {
           
            self.completion?(finalLocation)
            dismiss(animated: true)

        }

        
        
    }
    
    @objc private func didTapMap(gesture: UITapGestureRecognizer){
        
        let locationInView = gesture.location(in: map)
        self.finalLocation = map.convert(locationInView, toCoordinateFrom: map)
        
        let pin = MKPointAnnotation()
        
        for pin in map.annotations{
            map.removeAnnotation(pin)
            
        }
        
        if let finalLocation = self.finalLocation {
            pin.coordinate = finalLocation
            map.addAnnotation(pin)
        }
        
    }
    


}

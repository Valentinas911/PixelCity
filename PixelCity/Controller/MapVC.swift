//
//  MapVC.swift
//  PixelCity
//
//  Created by Valentinas Mirosnicenko on 5/1/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }

    @IBAction func locationButtonPressed(_ sender: Any) {
        
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    
    
}

